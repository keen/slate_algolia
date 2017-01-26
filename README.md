# Slate_Algolia

`slate_algolia` is a Middleman extension that allows you to easily and automatically index your [Slate docs](https://github.com/lord/slate) in [Algolia](https://www.algolia.com/)

## Installation

If you're not using Bundler, simply install the gem:

```ssh
gem install slate_algolia
```

If you are using Bundler, add `slate_algolia` to your Gemfile
```ruby
gem slate_algolia
```

and then reinstall your gems

```ssh
bundle install
```

## Configuration

The most simple way to activate the extension is to add this code to your `config.rb`:

```ruby
activate :slate_algolia do |options|
  options.application_id = 'ABCD'
  options.api_key = '1234'
end
```

You also need to add a line to the YAML Frontmatter of your Slate docs index. This is necessary because many companies embed Slate inside of a larger docs site.

```YAML
algolia_search: true
```

There are some additional configurations you can enable:

```ruby
activate :slate_algolia do |options|
  options.application_id = 'ABCD'  # Algolia Application ID
  options.api_key        = '1234'  # Algolia API Key
  options.dry_run        = true    # Don't send data to Algolia, but output some log information instead
  options.parsers        = {}      # Custom tag parsers (discussed later in the docs)
  options.before_index   = nil     # Proc for changing the data model before it is sent to Algolia
end
```

## Changing the Data Model

While the data model built in is pretty well thought-out, everyone's search needs will be different. Some projects of course will need to mold the data model to meet their needs. To do that, you can hook in to the indexing process and modify the records _just before_ they are shipped off to Algolia.

Set it up in your config file:

```ruby
activate :slate_algolia do |options|
  options.before_index = proc { |record|
    # Change the key name for the body to 'content'
    record[:content] = record[:body]
    record.delete(:body)

    record
  }
end
```

If you would like to turn a single record into multiple records, simply return an array of records

```ruby
activate :slate_algolia do |options|
  options.before_index = proc { |record|
    # Create a record for each language in the code examples
    record.permanent_code.map.with_index { |language, code|
      new_record = record.merge({
        code: code,
        language: language
      })
      new_record.delete(permanent_code)

      new_record
    }
  }
end
```

## Filtering Deletes

`slate_algolia` has automatic cleanup built in - meaning that after indexing new content, it will look through Algolia for any content that exists there but **does not** exist in the current content. It will remove those items, assuming they have been removed from the active content. However, you may not want to delete all of your unmatched records - perhaps they serve as a good synonym, or perhaps you index more than just slate docs in that Algolia index. There is a hook option you can use the filter out records from being deleted.

```ruby
activate :slate_algolia do |options|
  options.filter_deletes = proc { |record|
    if record['category'] == 'API Docs'
      true # Truthy values will be deleted
    else
      false # Non-Truthy values will be ignored
    end
  }
end
```


## Custom Tag Parser

TODO
