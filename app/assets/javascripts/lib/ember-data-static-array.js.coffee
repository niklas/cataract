DS.RESTAdapter.registerTransform 'staticArray',
  fromJSON: (serialized) -> serialized
  toJSON: (deserialized) -> deserialized

