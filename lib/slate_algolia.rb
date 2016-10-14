require 'middleman-core'

::Middleman::Extensions.register(:slate_algolia) do
    require 'slate_algolia/extension'
    ::Middleman::SlateAlgolia::Extension
end
