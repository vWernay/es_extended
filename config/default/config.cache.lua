Config.Modules.Cache = {
  -- in minutes, the amount of time between cache updates to the database
  EnableDebugging              = true,
  ServerSaveInterval           = 10,
  BasicCachedTables            = {
    "vehicles"
  },
  IdentityCachedTables         = {
    "owned_vehicles"
  },
  BasicCachedTablesToUpdate    = {
  },
  IdentityCachedTablesToUpdate = {
    "owned_vehicles"
  }
}
