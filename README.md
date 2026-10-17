## ComputedCustomField plugin for Redmine

[![Redmine compatibility](https://github.com/goodnewz/redmine_plugin_computed_custom_field/actions/workflows/test.yml/badge.svg)](https://github.com/goodnewz/redmine_plugin_computed_custom_field/actions/workflows/test.yml)

This fork maintains the plugin originally created by annikoff for Redmine 5, 6, and 7.

### Description:

This plugin provides a possibility to create a computed custom field.
The value of the computed field can be set by formula.
In formula constructions like `cfs[cf_id]` are replaced by IDs of custom fields.
A valid formula is a valid Ruby code executed when a customized object is updated.
To put a field ID in the formula, double-click on an item in the list of available fields.


![ComputedCustomField plugin for Redmine](https://raw.githubusercontent.com/annikoff/images/master/redmine_plugin_computed_custom_field_v_1_0_3.png)

### Changelog:

Plugin's changelog is available [here](CHANGELOG.md).

### Important information

This is a new version of the plugin. Since version 1.0.0 it is not compatible with previous versions.
The following constructions in formula `%{cf_id}` are no longer supported. Instead use `cfs[cf_id]`.
If you need to upgrade from older versions, please check out migration section.

> ### Notes:
> - cfs[cf_id] &mdash; must be an ID of existing custom field.
> - Be careful with code in a formula, if it would wrong your application can be crashed.
> - If a computed custom field was created after creating of a customized object you need to re-save an object to evaluate computations.
> - After updating of formula customized objects should be re-saved.

### Installation:

From your Redmine application directory, clone the plugin into `plugins/computed_custom_field`. The directory name must match the registered plugin ID.
```sh
git clone https://github.com/goodnewz/redmine_plugin_computed_custom_field.git plugins/computed_custom_field
```

Or download the [ZIP archive](https://github.com/goodnewz/redmine_plugin_computed_custom_field/archive/master.zip) and extract it into `plugins/computed_custom_field`.

Run migrations
```sh
RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=computed_custom_field
```

Restart Redmine after installing or updating the plugin.

### Migration:
- Navigate to plugin folder.
- Run `git pull`
- From the Redmine application directory, run `RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=computed_custom_field`.
- In computed CF's formulas replace `%{cf_id}` constructions by `cfs[cf_id]`.

### Compatibility

This branch targets Redmine 5.x, 6.x, and 7.x. Use a Ruby version supported by your Redmine release. Older Redmine versions require an older plugin revision.

The compatibility workflow runs against Redmine 5.1.12, 6.1.5, and 7.0.2 using the official Docker images and SQLite. It checks fresh installation, migration rollback and reinstall, unit and controller tests, production eager loading, and code reloads under lazy loading. The Redmine 7 job also runs the browser tests with headless Chromium. Other databases and combinations with other plugins require staging validation.

Full application reload checks run on Redmine 6 and 7. Redmine 5 has an [upstream core preparation bug](https://www.redmine.org/issues/38155), so its loading checks cover lazy/eager startup and repeated plugin patching without a full application reload.

### Testing

Run the same checks locally from this plugin checkout with Docker:

```sh
docker run --rm \
  --volume "$PWD:/usr/src/redmine/plugins/computed_custom_field:ro" \
  redmine:7.0.2 bash plugins/computed_custom_field/test/compatibility/run.sh
```

Replace `7.0.2` with `5.1.12` or `6.1.5` to check the other supported release lines. The script installs test dependencies and replaces the container's database configuration; run it only in a disposable container.

To run the unit and controller tests in an existing Redmine development checkout with its test database prepared:

```sh
RAILS_ENV=test bundle exec rake redmine:plugins:test NAME=computed_custom_field
```

Browser tests are kept in `test/ui` and can be run separately with `redmine:plugins:test:ui` when Chrome and the Redmine system-test dependencies are available. Add `--env RUN_UI_TESTS=1` to the Docker command above to include them in a local compatibility run.

### Examples:
```ruby
cfs[1]*2+cfs[2]
# means
# custom_field_value(1) * 2 + custom_field_value(2)
```

```ruby
(cfs[1]/3.14).round(2)
```

```ruby
if cfs[1].zero?
 cfs[2]/2
else
 cfs[3]/2
end
```

```ruby
# For IssueCustomField
(self.estimated_hours || 0) * 2
```

```ruby
# For ProjectCustomField
self.parent_id == 2
```

```ruby
# If format of Custom Field is Link
"/projects/#{self.project_id.to_s}/issues/new?issue[subject]=Review+request+[##{self.id.to_s} #{self.subject}]&issue[tracker_id]=3"
```

```ruby
# Retrieve a value from Key/value list custom field
cfs[1].try(:id)
```

To write formulas this documentation can be helpful:
- [Issue](http://www.rubydoc.info/github/edavis10/redmine/Issue)
- [Project](http://www.rubydoc.info/github/edavis10/redmine/Project)
- [User](http://www.rubydoc.info/github/edavis10/redmine/User)
- [TimeEntry](http://www.rubydoc.info/github/edavis10/redmine/TimeEntry)
- [Version](http://www.rubydoc.info/github/edavis10/redmine/Version)
- [Group](http://www.rubydoc.info/github/edavis10/redmine/Group)
- [Document](http://www.rubydoc.info/github/edavis10/redmine/Document)
- [TimeEntryActivity, IssuePriority, DocumentCategory](http://www.rubydoc.info/github/edavis10/redmine/Enumeration)


### Getting help

If you need help with a formula's code read [FAQ](https://github.com/annikoff/redmine_plugin_computed_custom_field/wiki/FAQ)
and check out [existing issues](https://github.com/annikoff/redmine_plugin_computed_custom_field/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3Aquestion+) 
or ask [Redmine community](https://www.redmine.org/projects/redmine/boards/2).

Licensed under the [MIT-LICENSE](MIT-LICENSE)
