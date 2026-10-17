require File.expand_path('../../test_helper', __FILE__)

class ComputedCustomFieldTest < ComputedCustomFieldTestCase
  def test_patch_models
    models = [Enumeration, Group, Issue, Project, TimeEntry, User, Version]
    models.each do |model|
      assert model.included_modules.include?(ComputedCustomField::ModelPatch)
    end
  end

  def test_patches_are_applied_without_eager_loading
    assert_includes CustomField.ancestors, ComputedCustomField::CustomFieldPatch
    assert_includes CustomFieldsHelper.ancestors, ComputedCustomField::CustomFieldsHelperPatch
    assert_includes Issue.ancestors, ComputedCustomField::IssuePatch
  end

  def test_repeated_preparation_does_not_duplicate_callbacks_or_patches
    2.times { ComputedCustomField.patch_models }

    callbacks = Issue._validation_callbacks.select { |callback| callback.filter == :eval_computed_fields }
    assert_equal 1, callbacks.size
    assert_equal 1, Issue.ancestors.count(ComputedCustomField::IssuePatch)
  end

  def test_computed_issue_fields_are_read_only_and_keep_workflow_restrictions
    field = field_with_string_format
    record = issue
    user = User.find(1)
    record.expects(:workflow_rule_by_attribute).with(user).twice.returns('subject' => 'readonly')

    attributes = record.read_only_attribute_names(user)

    assert_includes attributes, 'subject'
    assert_includes attributes, field.id.to_s
    refute_includes record.editable_custom_field_values(user).map(&:custom_field_id), field.id
  end
end
