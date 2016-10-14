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
The most simple way to activate this is to add this code to your `config.rb`:

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

## Configuration

There are some additional configurations you can enable:

```ruby
activate :slate_algolia do |options|
  options.application_id = 'ABCD'  # Algolia Application ID
  options.api_key        = '1234'  # Algolia API Key
  options.dry_run        = true    # Don't send data to Algolia, but output some log information instead
  options.parsers        = {}      # Custom tag parsers (discussed later in the docs)
end
```

## Custom Tag Parser

TODO
