Deckhand.app.factory "ModelConfig", ['ModelConfigData', (ModelConfigData) ->
  field = (model, name, relation) ->
    return null unless ModelConfigData[model]
    if relation
      className = ModelConfigData[model][relation].class_name
      return null unless ModelConfigData[className]
      ModelConfigData[className][name]
    else
      ModelConfigData[model][name]

  type = (model, name) ->
    f = field(model, name)
    (if f then f.type else null)

  tableFields = (model) ->
    modelConfig = ModelConfigData[model]
    return [] unless modelConfig
    Object.keys(modelConfig).filter((name) ->
      modelConfig.hasOwnProperty name
    ).map (name) -> modelConfig[name]

  {
    field: field
    type: type
    tableFields: tableFields
  }
]
