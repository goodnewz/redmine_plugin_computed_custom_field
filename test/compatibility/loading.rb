# Check production eager loading and development-style lazy loading/reloading.
def assert_patches
  {
    CustomField => 'ComputedCustomField::CustomFieldPatch',
    CustomFieldsHelper => 'ComputedCustomField::CustomFieldsHelperPatch',
    Issue => 'ComputedCustomField::IssuePatch'
  }.each do |target, patch|
    raise "Missing or duplicated #{patch}" unless target.ancestors.map(&:name).count(patch) == 1
  end

  [Enumeration, Group, Issue, Project, TimeEntry, User, Version].each do |model|
    callbacks = model._validation_callbacks.count { |callback| callback.filter == :eval_computed_fields }
    raise "Missing or duplicated calculation callback on #{model}" unless callbacks == 1
  end

  listeners = Redmine::Hook.hook_listeners(:view_custom_fields_form_upper_box)
  count = listeners.count { |listener| listener.class.name == 'ComputedCustomField::Hooks' }
  raise 'Missing or duplicated form hook' unless count == 1

  field = IssueCustomField.new(name: 'Loading regression', field_format: 'float',
                               is_computed: true, formula: '1/0')
  raise 'Formula validation is missing' if field.valid? || field.errors[:formula].empty?
end

assert_patches
2.times do
  if Rails.application.config.eager_load || Rails.application.config.cache_classes
    ComputedCustomField.patch_models
  else
    Rails.application.reloader.reload!
  end
  assert_patches
end
puts "Loading checks passed (Redmine #{Redmine::VERSION}, eager_load=#{Rails.application.config.eager_load})"
