require 'middleman-core'
require 'slate_algolia/index'
require 'slate_algolia/parser'
require 'slate_algolia/extension'

::Middleman::Extensions.register(:slate_algolia) do
    ::Middleman::SlateAlgolia::Extension
end
