import datetime
import email
import quopri
import re
import requests
import six
from six.moves.urllib.parse import urlparse
import uuid

from behave import when, then
from behaving.personas.steps import *  # noqa: F401, F403
from behaving.mail.steps import *  # noqa: F401, F403
from behaving.web.steps import *  # noqa: F401, F403

# Monkey-patch Selenium 3 to handle Python 3.9
import base64
if not hasattr(base64, 'encodestring'):
    base64.encodestring = base64.encodebytes

# Monkey-patch Behaving to handle function rename
from behaving.web.steps import forms
if not hasattr(forms, 'fill_in_elem_by_name'):
    forms.fill_in_elem_by_name = forms.i_fill_in_field

URL_RE = re.compile(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|\
                    (?:%[0-9a-fA-F][0-9a-fA-F]))+', re.I | re.S | re.U)
SINGLE_QUOTE_RE = re.compile(r"(^|[^\\])'")

dataset_default_schema = """
    {"fields": [
        {"format": "default", "name": "Game Number", "type": "integer"},
        {"format": "default", "name": "Game Length", "type": "integer"}
    ],
    "missingValues": ["Default schema"]
    }
"""

resource_default_schema = """
    {"fields": [
        {"format": "default", "name": "Game Number", "type": "integer"},
        {"format": "default", "name": "Game Length", "type": "integer"}
    ],
    "missingValues": ["Resource schema"]
    }
"""


@when(u'I take a debugging screenshot')
def debug_screenshot(context):
    """ Take a screenshot only if debugging is enabled in the persona.
    """
    if context.persona and context.persona.get('debug') == 'True':
        context.execute_steps(u"""
            When I take a screenshot
        """)


@when(u'I go to homepage')
def go_to_home(context):
    context.execute_steps(u"""
        When I visit "/"
    """)


@when(u'I go to register page')
def go_to_register_page(context):
    context.execute_steps(u"""
        When I go to homepage
        And I press "Register"
    """)


@when(u'I log in')
def log_in(context):
    context.execute_steps(u"""
        When I go to homepage
        And I expand the browser height
        And I press "Log in"
        Then I should see an element with xpath "//a[@href='/user/login/oidc-pkce']"
        When I log in directly
    """)


@when(u'I expand the browser height')
def expand_height(context):
    # Work around x=null bug in Selenium set_window_size
    context.browser.driver.set_window_rect(x=0, y=0, width=1024, height=3072)


@when(u'I log in directly')
def log_in_directly(context):
    """
    This differs to the `log_in` function above by logging in directly to a page where the user login form is presented
    :param context:
    :return:
    """

    assert context.persona, "A persona is required to log in, found [{}] in context. Have you configured the personas in before_scenario?".format(context.persona)
    context.execute_steps(u"""
        When I attempt to log in with password "$password"
        Then I should see an element with xpath "//*[@title='Log out']/i[contains(@class, 'fa-sign-out')]"
    """)


@when(u'I attempt to log in with password "{password}"')
def attempt_login(context, password):
    assert context.persona
    context.execute_steps(u"""
        When I fill in "login" with "$name"
        And I fill in "password" with "{}"
        And I press the element with xpath "//button[contains(string(), 'Login')]"
    """.format(password))


@then(u'I should see the login form')
def login_link_visible(context):
    context.execute_steps(u"""
        Then I should see an element with xpath "//h1[contains(string(), 'Login')]"
    """)


@when(u'I request a password reset')
def request_reset(context):
    assert context.persona
    context.execute_steps(u"""
        When I visit "/user/reset"
        And I fill in "user" with "$name"
        And I press the element with xpath "//button[contains(string(), 'Request Reset')]"
    """)


@when(u'I fill in "{name}" with "{value}" if present')
def fill_in_field_if_present(context, name, value):
    context.execute_steps(u"""
        When I execute the script "field = $('#field-{0}'); if (!field.length) field = $('#{0}'); if (!field.length) field = $('[name={0}]'); field.val('{1}'); field.keyup();"
    """.format(name, value))


@when(u'I clear the URL field')
def clear_url(context):
    context.execute_steps(u"""
        When I execute the script "$('a.btn-remove-url:contains(Clear)').click();"
    """)


@when(u'I confirm the dialog containing "{text}" if present')
def confirm_dialog_if_present(context, text):
    dialog_xpath = "//*[contains(@class, 'modal-dialog') and contains(string(), '{0}')]".format(text)
    if context.browser.is_element_present_by_xpath(dialog_xpath):
        parent_xpath = dialog_xpath
    elif context.browser.is_text_present(text):
        parent_xpath = "//div[contains(string(), '{0}')]/..".format(text)
    else:
        return
    button_xpath = parent_xpath + "//button[contains(@class, 'btn-primary')]"
    context.execute_steps(u"""
        When I take a debugging screenshot
        And I press the element with xpath "{0}"
    """.format(button_xpath))


@when(u'I confirm dataset deletion')
def confirm_dataset_deletion_dialog_if_present(context):
    dialog_text = "Briefly describe the reason for deleting this dataset"
    if context.browser.is_text_present(dialog_text):
        context.execute_steps(u"""
            Then I should see an element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary' and @disabled='disabled']"
            When I fill in "deletion-reason" with "it should be longer than 10 characters" if present
            Then I should not see an element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary' and @disabled='disabled']"
        """)
    # Press the Confirm button whether it is in a dialog or a page
    context.execute_steps(u"""
        When I press the element with xpath "//button[contains(@class, 'btn-primary') and contains(string(), 'Confirm') ]"
        Then I should see "Dataset has been deleted"
    """)


@when(u'I open the new resource form for dataset "{name}"')
def go_to_new_resource_form(context, name):
    context.execute_steps(u"""
        When I edit the "{0}" dataset
    """.format(name))
    if context.browser.is_element_present_by_xpath("//*[contains(@class, 'btn-primary') and contains(string(), 'Next:')]"):
        # Draft dataset, proceed directly to resource form
        context.execute_steps(u"""
            When I press "Next:"
        """)
    else:
        # Existing dataset, browse to the resource form
        context.execute_steps(u"""
            When I press "Resources"
            And I press "Add new resource"
            And I take a debugging screenshot
        """)


@when(u'I fill in title with random text')
def title_random_text(context):
    assert context.persona
    context.execute_steps(u"""
        When I fill in "title" with "Test Title {0}"
        And I fill in "name" with "test-title-{0}" if present
        And I set "last_generated_title" to "Test Title {0}"
        And I set "last_generated_name" to "test-title-{0}"
    """.format(uuid.uuid4()))


@when(u'I go to dataset page')
def go_to_dataset_page(context):
    context.execute_steps(u"""
        When I visit "/dataset"
    """)


@when(u'I go to dataset "{name}"')
def go_to_dataset(context, name):
    context.execute_steps(u"""
        When I visit "/dataset/{0}"
        And I take a debugging screenshot
    """.format(name))


@when(u'I go to the first resource in the dataset')
def go_to_first_resource(context):
    context.execute_steps(u"""
        When I press the element with xpath "//li[@class="resource-item"]/a"
        And I take a debugging screenshot
    """)


@when(u'I show all the fields')
def show_more_fields(context):
    """
    Click the 'Show more' link, if present, to reveal all the metadata.
    """
    context.execute_steps(u"""
        When I execute the script "$('a.show-more').click()"
    """)


@when(u'I edit the "{name}" dataset')
def edit_dataset(context, name):
    context.execute_steps(u"""
        When I visit "/dataset/edit/{0}"
    """.format(name))


@when(u'I select the "{licence_id}" licence')
def select_licence(context, licence_id):
    # Licence requires special interaction due to fancy JavaScript
    context.execute_steps(u"""
        When I execute the script "$('#field-license_id').val('{0}').trigger('change')"
    """.format(licence_id))


@when(u'I enter the resource URL "{url}"')
def enter_resource_url(context, url):
    if url != "default":
        context.execute_steps(u"""
            When I clear the URL field
            When I execute the script "$('#resource-edit [name=url]').val('{0}')"
        """.format(url))


@when(u'I fill in default dataset fields')
def fill_in_default_dataset_fields(context):
    context.execute_steps(u"""
        When I fill in title with random text
        And I fill in "notes" with "Description"
        And I fill in "version" with "1.0"
        And I fill in "author_email" with "test@me.com"
        And I select the "other-open" licence
        And I fill in "de_identified_data" with "NO" if present
    """)


@when(u'I fill in default resource fields')
def fill_in_default_resource_fields(context):
    context.execute_steps(u"""
        When I fill in "name" with "Test Resource"
        And I fill in "description" with "Test Resource Description"
        And I fill in "size" with "1024" if present
    """)


@when(u'I fill in link resource fields')
def fill_in_default_link_resource_fields(context):
    context.execute_steps(u"""
        When I enter the resource URL "https://example.com"
        And I execute the script "document.getElementById('field-format').value='HTML'"
        And I fill in "size" with "1024" if present
    """)


@when(u'I upload "{file_name}" of type "{file_format}" to resource')
def upload_file_to_resource(context, file_name, file_format):
    context.execute_steps(u"""
        When I execute the script "$('#resource-upload-button').trigger('click');"
        And I attach the file "{file_name}" to "upload"
        # Don't quote the injected string since it can have trailing spaces
        And I execute the script "document.getElementById('field-format').value='{file_format}'"
        And I fill in "size" with "1024" if present
    """.format(file_name=file_name, file_format=file_format))


@when(u'I upload schema file "{file_name}" to resource')
def upload_schema_file_to_resource(context, file_name):
    context.execute_steps(u"""
        When I execute the script "$('#field-schema-json ~ a.btn-remove-url').trigger('click');"
        And I attach the file "{file_name}" to "schema_upload"
    """.format(file_name=file_name))


@when(u'I go to group page')
def go_to_group_page(context):
    context.execute_steps(u"""
        When I visit "/group"
    """)


@when(u'I go to organisation page')
def go_to_organisation_page(context):
    context.execute_steps(u"""
        When I visit "/organization"
    """)


@when(u'I search the autocomplete API for user "{username}"')
def go_to_user_autocomplete(context, username):
    context.execute_steps(u"""
        When I visit "/api/2/util/user/autocomplete?q={0}"
    """.format(username))


@when(u'I go to the user list API')
def go_to_user_list(context):
    context.execute_steps(u"""
        When I visit "/api/3/action/user_list"
    """)


@when(u'I go to the "{user_id}" profile page')
def go_to_user_profile(context, user_id):
    context.execute_steps(u"""
        When I visit "/user/{0}"
    """.format(user_id))


@when(u'I go to the dashboard')
def go_to_dashboard(context):
    context.execute_steps(u"""
        When I visit "/dashboard/datasets"
    """)


@then(u'I should see my datasets')
def dashboard_datasets(context):
    context.execute_steps(u"""
        Then I should see an element with xpath "//li[contains(@class, 'active') and contains(string(), 'My Datasets')]"
    """)


@when(u'I go to the "{user_id}" user API')
def go_to_user_show(context, user_id):
    context.execute_steps(u"""
        When I visit "/api/3/action/user_show?id={0}"
    """.format(user_id))


@when(u'I view the "{group_id}" {group_type} API "{including}" users')
def go_to_group_including_users(context, group_id, group_type, including):
    if group_type == "organisation":
        group_type = "organization"
    context.execute_steps(u"""
        When I visit "/api/3/action/{1}_show?id={0}&include_users={2}"
    """.format(group_id, group_type, including in ['with', 'including']))


@then(u'I should be able to download via the element with xpath "{expression}"')
def test_download_element(context, expression):
    url = context.browser.find_by_xpath(expression).first['href']
    assert requests.get(url, cookies=context.browser.cookies.all()).status_code == 200


@then(u'I should be able to patch dataset "{package_id}" via the API')
def test_package_patch(context, package_id):
    url = context.base_url + 'api/action/package_patch'
    response = requests.post(url, json={'id': package_id}, cookies=context.browser.cookies.all())
    print("Response from endpoint {} is: {}, {}".format(url, response, response.text))
    assert response.status_code == 200
    assert '"success": true' in response.text


# Parse a "key=value::key2=value2" parameter string and return an iterator of (key, value) pairs.
def _parse_params(param_string):
    params = {}
    for param in param_string.split("::"):
        entry = param.split("=", 1)
        params[entry[0]] = entry[1] if len(entry) > 1 else ""
    return six.iteritems(params)


@when(u'I show the non-JavaScript schema fields')
def reveal_non_js_schema_fields(context):
    context.execute_steps(u"""
        When I execute the script "$('#resource-schema-buttons ~ div.form-group').attr('style', '')"
    """)


@when(u'I set the resource schema to the dataset default')
def set_resource_schema_to_dataset_default(context):
    _enter_manual_schema(context, dataset_default_schema)


# Enter a JSON schema value
# This can require JavaScript interaction, and doesn't fit well into
# a step invocation due to all the double quotes.
def _enter_manual_schema(context, schema_json):
    # Click the button to select manual JSON input if it exists
    context.execute_steps(u"""
        When I execute the script "$('a.btn[title*=JSON]:contains(JSON)').click();"
    """)
    # Call function directly so we can properly quote our parameter
    forms.fill_in_elem_by_name(context, "schema_json", schema_json)


def _create_dataset_from_params(context, params):
    context.execute_steps(u"""
        When I visit "/dataset/new"
        And I fill in default dataset fields
    """)
    if 'private' not in params:
        params = params + "::private=False"
    for key, value in _parse_params(params):
        if key == "name":
            # 'name' doesn't need special input, but we want to remember it
            context.execute_steps(u"""
                When I set "last_generated_name" to "{0}"
            """.format(value))

        # Don't use elif here, we still want to type 'name' as usual
        if key == "owner_org":
            # Owner org uses UUIDs as its values, so we need to rely on displayed text
            context.execute_steps(u"""
                When I select by text "{1}" from "{0}"
            """.format(key, value))
        elif key in ["update_frequency", "request_privacy_assessment", "private"]:
            context.execute_steps(u"""
                When I select "{1}" from "{0}"
            """.format(key, value))
        elif key == "license_id":
            context.execute_steps(u"""
                When I select the "{0}" licence
            """.format(value))
        elif key == "schema_json":
            if value == "default":
                value = dataset_default_schema
            _enter_manual_schema(context, value)
        else:
            context.execute_steps(u"""
                When I fill in "{0}" with "{1}" if present
            """.format(key, value))
    context.execute_steps(u"""
        When I take a debugging screenshot
        And I press "Add Data"
        Then I should see "Add New Resource"
    """)


@when(u'I create a dataset with key-value parameters "{params}"')
def create_dataset_from_params(context, params):
    _create_dataset_from_params(context, params)
    context.execute_steps(u"""
        When I go to dataset "$last_generated_name"
    """)


@when(u'I create a dataset and resource with key-value parameters "{params}" and "{resource_params}"')
def create_dataset_and_resource_from_params(context, params, resource_params):
    _create_dataset_from_params(context, params)
    context.execute_steps(u"""
        When I create a resource with key-value parameters "{0}"
        Then I should see "Data and Resources"
    """.format(resource_params))


def _is_truthy(text):
    return text and text.lower() in ["true", "t", "yes", "y"]


def _get_yn_value(value, y_value="TRUE", n_value="FALSE"):
    return y_value if _is_truthy(value) else n_value


# Creates a resource using default values apart from the ones specified.
# The browser should already be on the create/edit resource page.
@when(u'I create a resource with key-value parameters "{resource_params}"')
def create_resource_from_params(context, resource_params):
    context.execute_steps(u"""
        When I fill in default resource fields
        And I fill in link resource fields
    """)
    for key, value in _parse_params(resource_params):
        if key == "url":
            context.execute_steps(u"""
                When I enter the resource URL "{0}"
            """.format(value))
        elif key == "upload":
            if value == "default":
                value = "test_game_data.csv"
            context.execute_steps(u"""
                When I clear the URL field
                And I execute the script "$('#resource-upload-button').click();"
                And I attach the file "{0}" to "upload"
            """.format(value))
        elif key == "format":
            context.execute_steps(u"""
                When I execute the script "document.getElementById('field-format').value='{0}'"
            """.format(value))
        elif key in ["align_default_schema"]:
            action = _get_yn_value(value, "check", "uncheck")
            context.execute_steps(u"""
                When I {0} "{1}"
            """.format(action, key))
        elif key == "resource_visible":
            option = _get_yn_value(value)
            context.execute_steps(u"""
                When I select "{1}" from "{0}"
            """.format(key, option))
        elif key in ["governance_acknowledgement", "request_privacy_assessment"]:
            option = _get_yn_value(value, "YES", "NO")
            context.execute_steps(u"""
                When I select "{1}" from "{0}"
            """.format(key, option))
        elif key == "schema":
            if value == "default":
                value = resource_default_schema
            _enter_manual_schema(context, value)
        elif key == "schema_upload":
            if value == "default":
                value = "test-resource_schemea.json"
            context.execute_steps(u"""
                When I upload schema file "{0}" to resource
            """.format(value))
        else:
            context.execute_steps(u"""
                When I fill in "{0}" with "{1}" if present
            """.format(key, value))
    context.execute_steps(u"""
        When I take a debugging screenshot
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I take a debugging screenshot
    """)


@then(u'I should receive a base64 email at "{address}" containing "{text}"')
def should_receive_base64_email_containing_text(context, address, text):
    should_receive_base64_email_containing_texts(context, address, text, None)


@then(u'I should receive a base64 email at "{address}" containing both "{text}" and "{text2}"')
def should_receive_base64_email_containing_texts(context, address, text, text2):
    # The default behaving step does not convert base64 emails
    # Modified the default step to decode the payload from base64
    def filter_contents(mail):
        mail = email.message_from_string(mail)
        payload = mail.get_payload()
        payload += "=" * ((4 - len(payload) % 4) % 4)  # do fix the padding error issue
        payload_bytes = quopri.decodestring(payload)
        if len(payload_bytes) > 0:
            payload_bytes += b'='  # do fix the padding error issue
        if six.PY2:
            decoded_payload = payload_bytes.decode('base64')
        else:
            import base64
            decoded_payload = six.ensure_text(base64.b64decode(six.ensure_binary(payload_bytes)))
        print('Searching for', text, ' and ', text2, ' in decoded_payload: ', decoded_payload)
        return text in decoded_payload and (not text2 or text2 in decoded_payload)

    assert context.mail.user_messages(address, filter_contents)


@when(u'I go to admin config page')
def go_to_admin_config(context):
    context.execute_steps(u"""
        When I visit "/ckan-admin/config"
    """)


@when(u'I log out')
def log_out(context):
    context.execute_steps(u"""
        When I press the element with xpath "//*[@title='Log out']"
        Then I should see "Log in"
    """)


@when(u'I reload page every {seconds:d} seconds until I see an element with xpath "{xpath}" but not more than {reload_times:d} times')
def reload_page_every_n_until_find(context, xpath, seconds=5, reload_times=5):
    for _ in range(reload_times):
        element = context.browser.is_element_present_by_xpath(
            xpath, wait_time=seconds
        )
        if element:
            assert element, 'Element with xpath "{}" was found'.format(xpath)
            return
        else:
            print("Element with xpath '{}' was not found, reloading at {}...".format(xpath, datetime.datetime.now()))
            context.browser.reload()

    assert False, 'Element with xpath "{}" was not found'.format(xpath)


# ckanext-validation-schema-generator


@when(u'I visit resource schema generation page')
def resource_schema_generation(context):
    path = urlparse(context.browser.url).path
    context.execute_steps(u"""
        When I visit "{0}/generate_schema"
    """.format(path))


# ckanext-data-qld


@when(u'I trigger notification about updated privacy assessment results')
def i_trigger_notification_assessment_results(context):
    context.execute_steps(u"""
        When I visit "api/action/qld_test_trigger_notify_privacy_assessment_result"
    """)


@when(u'I click the resource link in the email I received at "{address}"')
def click_link_in_email(context, address):
    mails = context.mail.user_messages(address)
    assert mails, u"message not found"

    mail = email.message_from_string(mails[-1])
    links = []

    payload = mail.get_payload(decode=True).decode("utf-8")
    links = URL_RE.findall(payload.replace("=\n", ""))

    assert links, u"link not found"
    url = links[0].rstrip(':')

    context.browser.visit(url)


# ckanext-ytp-comments


@when(u'I go to dataset "{name}" comments')
def go_to_dataset_comments(context, name):
    context.execute_steps(u"""
        When I go to dataset "%s"
        And I press "Comments"
    """ % (name))


@then(u'I should see the add comment form')
def comment_form_visible(context):
    context.execute_steps(u"""
        Then I should see an element with xpath "//textarea[@name='comment']"
    """)


@then(u'I should not see the add comment form')
def comment_form_not_visible(context):
    context.execute_steps(u"""
        Then I should not see an element with xpath "//input[@name='subject']"
        And I should not see an element with xpath "//textarea[@name='comment']"
    """)


def escape_for_javascript_string(text):
    """ Escape a text so that it's suitable to be injected into a
    single-quoted JavaScript string.
    """
    return SINGLE_QUOTE_RE.sub(r"\1\\'", text)


@when(u'I submit a comment with subject "{subject}" and comment "{comment}"')
def submit_comment_with_subject_and_comment(context, subject, comment):
    """
    There can be multiple comment forms per page (add, edit, reply) each with fields named "subject" and "comment"
    This step overcomes a limitation of the fill() method which only fills a form field by name
    :param context:
    :param subject:
    :param comment:
    :return:
    """
    context.browser.execute_script("""
        document.querySelector('form#comment_form input[name="subject"]').value = '%s';
        """ % escape_for_javascript_string(subject))
    context.browser.execute_script("""
        document.querySelector('form#comment_form textarea[name="comment"]').value = '%s';
        """ % escape_for_javascript_string(comment))
    context.browser.execute_script("""
        document.querySelector('form#comment_form .form-actions input[type="submit"]').click();
        """)


@when(u'I submit a reply with comment "{comment}"')
def submit_reply_with_comment(context, comment):
    """
    There can be multiple comment forms per page (add, edit, reply) each with fields named "subject" and "comment"
    This step overcomes a limitation of the fill() method which only fills a form field by name
    :param context:
    :param comment:
    :return:
    """
    context.browser.execute_script("""
        document.querySelector('.comment-wrapper form textarea[name="comment"]').value = '%s';
        """ % comment)
    context.browser.execute_script("""
        document.querySelector('.comment-wrapper form .form-actions input[type="submit"]').click();
        """)


# ckanext-qgov


@when(u'I lock my account')
def lock_account(context):
    context.execute_steps(u"""
        When I visit "/user/login"
    """)
    for x in range(11):
        context.execute_steps(u"""
            When I attempt to log in with password "incorrect password"
            Then I should see "Bad username or password or reCAPTCHA."
        """)


# ckanext-datarequests


@when(u'I go to the data requests page containing "{keyword}"')
def go_to_datarequest_page_search(context, keyword):
    context.execute_steps(u"""
        When I visit "/datarequest?q={0}"
    """.format(keyword))


@when(u'I go to the data requests page')
def go_to_datarequest_page(context):
    context.execute_steps(u"""
        When I visit "/datarequest"
    """)


@when(u'I go to data request "{subject}"')
def go_to_data_request(context, subject):
    context.execute_steps(u"""
        When I go to the data requests page containing "{0}"
        And I click the link with text "{0}"
        Then I should see "{0}" within 5 seconds
    """.format(subject))


@when(u'I create a datarequest')
def create_datarequest(context):
    assert context.persona
    context.execute_steps(u"""
        When I create a data request in the "Open Data Administration" organisation
    """)


@when(u'I create a data request in the "{organisation_name}" organisation')
def create_datarequest_for_org(context, organisation_name):
    assert context.persona
    context.execute_steps(u"""
        When I go to the data requests page
        And I press "Add data request"
        And I fill in title with random text
        And I fill in "description" with "Test description"
        And I execute the script "$('#field-organizations option:contains("{0}")').attr('selected', true)"
        And I take a debugging screenshot
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        And I take a debugging screenshot
    """.format(organisation_name))


@when(u'I go to data request "{subject}" comments')
def go_to_data_request_comments(context, subject):
    context.execute_steps(u"""
        When I go to data request "%s"
        And I press "Comments"
    """ % (subject))


# ckanext-report


@when(u'I go to my reports page')
def go_to_reporting_page(context):
    context.execute_steps(u"""
        When I visit "/dashboard/reporting"
    """)
