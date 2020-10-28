Config.Modules.Cache = {
  -- in minutes, the amount of time between cache updates to the database
  UseCache                     = true,
  EnableDebugging              = false,
  ServerSaveInterval           = 10,
  BasicCachedTables            = {
    "vehicles",
    "usedPlates"
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
