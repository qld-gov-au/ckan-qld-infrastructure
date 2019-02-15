#!/usr/bin/python
# -*- coding: utf-8 -*-

# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

DOCUMENTATION = '''
---
module: postgresql_db
short_description: Add or remove PostgreSQL databases from a remote host.
description:
   - Add or remove PostgreSQL databases from a remote host.
version_added: "0.6"
options:
  name:
    description:
      - name of the database to add or remove
    required: true
    default: null
  login_user:
    description:
      - The username used to authenticate with
    required: false
    default: null
  login_password:
    description:
      - The password used to authenticate with
    required: false
    default: null
  login_host:
    description:
      - Host running the database
    required: false
    default: localhost
  login_unix_socket:
    description:
      - Path to a Unix domain socket for local connections
    required: false
    default: null
  owner:
    description:
      - Name of the role to set as owner of the database
    required: false
    default: null
  port:
    description:
      - Database port to connect to.
    required: false
    default: 5432
  template:
    description:
      - Template used to create the database
    required: false
    default: null
  encoding:
    description:
      - Encoding of the database
    required: false
    default: null
  lc_collate:
    description:
      - Collation order (LC_COLLATE) to use in the database. Must match collation order of template database unless C(template0) is used as template.
    required: false
    default: null
  lc_ctype:
    description:
      - Character classification (LC_CTYPE) to use in the database (e.g. lower, upper, ...) Must match LC_CTYPE of template database unless C(template0) is used as template.
    required: false
    default: null
  state:
    description:
      - The database state
    required: false
    default: present
    choices: [ "present", "absent", "dump", "restore" ]
    backup:
      - Back up to a destination, requires target as well. Supported formats are
        .gz, .tar, .bz, .xz, and .sql
  restore:
    version_added: "2.2"
    description:
      - Restore from a destination. See backup for supported options
  target:
    version_added: "2.2"
    description:
      - File to back up or restore from.

notes:
   - The default authentication assumes that you are either logging in as or sudo'ing to the C(postgres) account on the host.
   - This module uses I(psycopg2), a Python PostgreSQL database adapter. You must ensure that psycopg2 is installed on
     the host before using this module. If the remote host is the PostgreSQL server (which is the default case), then PostgreSQL must also be installed on the remote host. For Ubuntu-based systems, install the C(postgresql), C(libpq-dev), and C(python-psycopg2) packages on the remote host before using this module.
requirements: [ psycopg2 ]
author: "Ansible Core Team"
'''

EXAMPLES = '''
# Create a new database with name "acme"
- postgresql_db: name=acme

# Create a new database with name "acme" and specific encoding and locale
# settings. If a template different from "template0" is specified, encoding
# and locale settings must match those of the template.
- postgresql_db: name=acme
                 encoding='UTF-8'
                 lc_collate='de_DE.UTF-8'
                 lc_ctype='de_DE.UTF-8'
                 template='template0'
'''

try:
    import psycopg2
    import psycopg2.extras
    import pipes
    import subprocess
    import os

except ImportError:
    postgresqldb_found = False
else:
    postgresqldb_found = True
from ansible.module_utils.six import iteritems

class NotSupportedError(Exception):
    pass


# ===========================================
# PostgreSQL module specific support methods.
#

def set_owner(cursor, db, owner):
    query = "ALTER DATABASE %s OWNER TO %s" % (
            pg_quote_identifier(db, 'database'),
            pg_quote_identifier(owner, 'role'))
    cursor.execute(query)
    return True

def get_encoding_id(cursor, encoding):
    query = "SELECT pg_char_to_encoding(%(encoding)s) AS encoding_id;"
    cursor.execute(query, {'encoding': encoding})
    return cursor.fetchone()['encoding_id']

def get_db_info(cursor, db):
    query = """
    SELECT rolname AS owner,
    pg_encoding_to_char(encoding) AS encoding, encoding AS encoding_id,
    datcollate AS lc_collate, datctype AS lc_ctype
    FROM pg_database JOIN pg_roles ON pg_roles.oid = pg_database.datdba
    WHERE datname = %(db)s
    """
    cursor.execute(query, {'db': db})
    return cursor.fetchone()

def db_exists(cursor, db):
    query = "SELECT * FROM pg_database WHERE datname=%(db)s"
    cursor.execute(query, {'db': db})
    return cursor.rowcount == 1

def db_delete(cursor, db):
    if db_exists(cursor, db):
        query = "DROP DATABASE %s" % pg_quote_identifier(db, 'database')
        cursor.execute(query)
        return True
    else:
        return False

def db_create(cursor, db, owner, template, encoding, lc_collate, lc_ctype):
    params = dict(enc=encoding, collate=lc_collate, ctype=lc_ctype)
    if not db_exists(cursor, db):
        query_fragments = ['CREATE DATABASE %s' % pg_quote_identifier(db, 'database')]
        if owner:
            query_fragments.append('OWNER %s' % pg_quote_identifier(owner, 'role'))
        if template:
            query_fragments.append('TEMPLATE %s' % pg_quote_identifier(template, 'database'))
        if encoding:
            query_fragments.append('ENCODING %(enc)s')
        if lc_collate:
            query_fragments.append('LC_COLLATE %(collate)s')
        if lc_ctype:
            query_fragments.append('LC_CTYPE %(ctype)s')
        query = ' '.join(query_fragments)
        cursor.execute(query, params)
        return True
    else:
        db_info = get_db_info(cursor, db)
        if (encoding and
            get_encoding_id(cursor, encoding) != db_info['encoding_id']):
            raise NotSupportedError(
                'Changing database encoding is not supported. '
                'Current encoding: %s' % db_info['encoding']
            )
        elif lc_collate and lc_collate != db_info['lc_collate']:
            raise NotSupportedError(
                'Changing LC_COLLATE is not supported. '
                'Current LC_COLLATE: %s' % db_info['lc_collate']
            )
        elif lc_ctype and lc_ctype != db_info['lc_ctype']:
            raise NotSupportedError(
                'Changing LC_CTYPE is not supported.'
                'Current LC_CTYPE: %s' % db_info['lc_ctype']
            )
        elif owner and owner != db_info['owner']:
            return set_owner(cursor, db, owner)
        else:
            return False

def db_matches(cursor, db, owner, template, encoding, lc_collate, lc_ctype):
    if not db_exists(cursor, db):
       return False
    else:
        db_info = get_db_info(cursor, db)
        if (encoding and
            get_encoding_id(cursor, encoding) != db_info['encoding_id']):
            return False
        elif lc_collate and lc_collate != db_info['lc_collate']:
            return False
        elif lc_ctype and lc_ctype != db_info['lc_ctype']:
            return False
        elif owner and owner != db_info['owner']:
            return False
        else:
            return True

def db_dump(module, target, db=None, host=None, user=None, port=None, password=None):
    cmd = module.get_bin_path('pg_dump', True)

    flags = ''
    if host:
      flags += ' --host={0}'.format(pipes.quote(host))
    if port:
      flags += ' --port={0}'.format(pipes.quote(port))
    if user:
      flags += ' --username={0}'.format(pipes.quote(user))
    if password:
      cmd = 'PGPASSWORD={0} {1}'.format(pipes.quote(password), cmd)

    flags += ' --clean'

    if os.path.splitext(target)[-1] == '.tar':
        flags += ' --format=t'


    #dbname is the last option on the db_dump and does not have any flags before it
    if db:
        flags += ' {0}'.format(pipes.quote(db));

    cmd += flags

    comp_prog_path = None
    if os.path.splitext(target)[-1] == '.gz':
      comp_prog_path = module.get_bin_path('gzip', True)
    elif os.path.splitext(target)[-1] == '.bz2':
      comp_prog_path = module.get_bin_path('bzip2', True)
    elif os.path.splitext(target)[-1] == '.xz':
      comp_prog_path = module.get_bin_path('xz', True)

    if comp_prog_path:
      cmd = '{0}|{1} > {2}'.format(cmd, comp_prog_path, pipes.quote(target))
    else:
      cmd = '{0} > {1}'.format(cmd, pipes.quote(target))

    rc, stderr, stdout = module.run_command(cmd, use_unsafe_shell=True)
    return rc, stdout, stderr

def db_import(module, target, db=None, host=None, user=None, port=None, password=None):
    # set initial flags. These are the same in pg_restore as psql
    cmd = module.get_bin_path('psql', True) #could be changed to pg_restore for .tar
    psql_in_use = True

    flags = ''
    if user:
        flags += ' --username={0}'.format(pipes.quote(user))
    if host:
        flags += ' --host={0}'.format(pipes.quote(host))
    if port:
        flags += ' --port={0}'.format(pipes.quote(port))

    if os.path.splitext(target)[-1] == '.tar':
      cmd = module.get_bin_path('pg_restore', True)
      psql_in_use = False
      flags += ' --format=Tar'

    comp_prog_path = None
    if os.path.splitext(target)[-1] == '.gz':
      comp_prog_path = "{0} -dc {1}".format(module.get_bin_path('gzip', True), target)
    elif os.path.splitext(target)[-1] == '.xz':
      comp_prog_path = "{0} -dc {1}".format(module.get_bin_path('bzip2', True), target)
    elif os.path.splitext(target)[-1] == '.sql':
      comp_prog_path = "{0} {1}".format(module.get_bin_path('cat', True), target)

    if password:
        cmd = 'PGPASSWORD={0} {1}'.format(pipes.quote(password), cmd)

    #dbname is the last option in psql, but for pg_restore its included as a flag
    if db:
      if psql_in_use:
        flags += ' {0}'.format(pipes.quote(db))
      else:
        flags += ' --dbname={0}'.format(pipes.quote(db))

    cmd += flags


    if comp_prog_path:
      cmd = '{0}|{1} '.format(comp_prog_path, cmd)
      rc, stdout, stderr = module.run_command(cmd, use_unsafe_shell=True)
      ##complicated python way vs dump way above
      #p1 = subprocess.Popen(comp_prog_path, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      #p2 = subprocess.Popen(cmd, stdin=p1.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
      #(stdout2, stderr2) = p2.communicate()
      #p1.stdout.close()
      #p1.wait()
      #if p1.returncode != 0:
      #  stderr1 = p1.stderr.read()
      #  return p1.returncode, '', stderr1
      #return p2.returncode, stdout2, stderr2
    else:
      cmd = '{0} < {1}'.format(cmd, pipes.quote(target))
      rc, stdout, stderr = module.run_command(cmd, use_unsafe_shell=True)
    return rc, stdout, stderr

# ===========================================
# Module execution.
#

def main():
    module = AnsibleModule(
        argument_spec=dict(
            login_user=dict(default="postgres"),
            login_password=dict(default=""),
            login_host=dict(default=""),
            login_unix_socket=dict(default=""),
            port=dict(default="5432"),
            db=dict(required=True, aliases=['name']),
            owner=dict(default=""),
            template=dict(default=""),
            encoding=dict(default=""),
            lc_collate=dict(default=""),
            lc_ctype=dict(default=""),
            target=dict(default=""),
            state=dict(default="present", choices=["absent", "present", "dump", "import"]),
        ),
        supports_check_mode = True
    )

    if not postgresqldb_found:
        module.fail_json(msg="the python psycopg2 module is required")

    db = module.params["db"]
    port = module.params["port"]
    owner = module.params["owner"]
    template = module.params["template"]
    encoding = module.params["encoding"]
    lc_collate = module.params["lc_collate"]
    lc_ctype = module.params["lc_ctype"]
    target = module.params["target"]
    state = module.params["state"]
    changed = False

    # To use defaults values, keyword arguments must be absent, so
    # check which values are empty and don't include in the **kw
    # dictionary
    params_map = {
        "login_host":"host",
        "login_user":"user",
        "login_password":"password",
        "port":"port"
    }


    kw = dict( (params_map[k], v) for (k, v) in module.params.iteritems()
              if k in params_map and v != '' )

    # If a login_unix_socket is specified, incorporate it here.
    is_localhost = "host" not in kw or kw["host"] == "" or kw["host"] == "localhost"

    if is_localhost and module.params["login_unix_socket"] != "":
        kw["host"] = module.params["login_unix_socket"]

    if target == "":
        target = "{0}/{1}.sql".format(os.getcwd(), db)
        target = os.path.expanduser(target)
    else:
        target = os.path.expanduser(target)

    try:
        db_connection = psycopg2.connect(database="postgres", **kw)

        # Enable autocommit so we can create databases
        if psycopg2.__version__ >= '2.4.2':
            db_connection.autocommit = True
        else:
            db_connection.set_isolation_level(psycopg2
                                              .extensions
                                              .ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = db_connection.cursor(
                cursor_factory=psycopg2.extras.DictCursor)
    except Exception:
        e = get_exception()
        module.fail_json(msg="unable to connect to database: %s" % e)

    try:
        if module.check_mode:
            if state == "absent":
                changed = not db_exists(cursor, db)
            elif state == "present":
                changed = not db_matches(cursor, db, owner, template, encoding,
                                         lc_collate, lc_ctype)
            module.exit_json(changed=changed,db=db)

        if state == "absent":
            try:
                changed = db_delete(cursor, db)
            except SQLParseError:
                e = get_exception()
                module.fail_json(msg=str(e))

        elif state == "present":
            try:
                changed = db_create(cursor, db, owner, template, encoding,
                                lc_collate, lc_ctype)
            except SQLParseError:
                e = get_exception()
                module.fail_json(msg=str(e))

        elif state == "dump":
            try:
                rc, stdout, stderr = db_dump(module, target, db, **kw)
                if rc != 0:
                    module.fail_json(msg="{0}".format(stderr))
                else:
                    module.exit_json(changed=True, msg=stdout)

            except Exception:
                e = get_exception()
                module.fail_json(msg=str(e))

        elif state == "import":
            try:
                rc, stdout, stderr = db_import(module, target, db, **kw)
                if rc != 0:
                  module.fail_json(msg="{0}".format(stderr))
                else:
                  module.exit_json(changed=True, msg=stdout)
            except Exception:
                e = get_exception()
            except SQLParseError:
                e = get_exception()
                module.fail_json(msg=str(e))

    except NotSupportedError:
        e = get_exception()
        module.fail_json(msg=str(e))
    except SystemExit:
        # Avoid catching this on Python 2.4
        raise
    except Exception:
        e = get_exception()
        module.fail_json(msg="Database query failed: %s" % e)

    module.exit_json(changed=changed, db=db)

# import module snippets
from ansible.module_utils.basic import *
from ansible.module_utils.database import *
if __name__ == '__main__':
    main()
