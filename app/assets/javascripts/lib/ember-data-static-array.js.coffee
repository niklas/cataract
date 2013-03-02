DS.RESTAdapter.registerTransform 'staticArray',
  deserialize: (serialized) -> serialized
  serialize: (deserialized) -> deserialized

