require_relative '../test_helper'

class ComputedCustomFieldsControllerTest < ActionController::TestCase
  tests CustomFieldsController
  fixtures FixturesHelper.fixtures

  def setup
    @request.session[:user_id] = 1
  end

  def test_new_custom_field_renders_computed_controls
    get :new, params: { type: 'IssueCustomField' }

    assert_response :success
    assert_select 'input#custom_field_is_computed'
    assert_select 'textarea#custom_field_formula'
    assert_select 'select#available_cfs'
  end

  def test_invalid_computed_formula_is_not_saved
    assert_no_difference 'CustomField.count' do
      post :create, params: {
        type: 'IssueCustomField',
        custom_field: { name: 'Invalid computed field', field_format: 'float',
                        is_computed: '1', formula: '1/0' }
      }
    end

    assert_select '#errorExplanation', text: /divided by 0/
  end

  def test_computed_formula_can_be_created_and_edited
    assert_difference 'CustomField.count' do
      post :create, params: {
        type: 'IssueCustomField',
        custom_field: { name: 'Computed field', field_format: 'float',
                        is_computed: '1', formula: 'estimated_hours.to_f * 2' }
      }
    end
    assert_response :redirect

    field = CustomField.order(:id).last
    assert field.is_computed?
    assert_equal 'estimated_hours.to_f * 2', field.formula

    put :update, params: { id: field.id, custom_field: { formula: 'estimated_hours.to_f * 3' } }
    assert_response :redirect
    assert_equal 'estimated_hours.to_f * 3', field.reload.formula

    get :edit, params: { id: field.id }
    assert_response :success
    assert_select 'input#custom_field_is_computed[disabled]'
    assert_select 'textarea#custom_field_formula', text: 'estimated_hours.to_f * 3'
  end
end
