Redmine::Plugin.register :computed_custom_field do
  name 'Computed custom field'
  author 'Yakov Annikov'
  url 'https://github.com/goodnewz/redmine_plugin_computed_custom_field'
  description ''
  version '1.0.7'
  requires_redmine version_or_higher: '5.0.0'
  settings default: {}
end

# Redmine loads plugin initializers in to_prepare, including after a code reload.
# Resolve patches through Zeitwerk each time so they apply to the current classes.
ComputedCustomField.patch_models
ComputedCustomField::Hooks.instance
