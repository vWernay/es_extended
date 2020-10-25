Config.Modules.cache = {
  -- in minutes, the amount of time between cache updates to the database
  serverSaveInterval = 10,
  basicCachedTables = {
    "vehicles"
  },
  identityCachedTables = {
    "owned_vehicles"
  },
  basicCachedTablesToUpdate = {
  },
  identityCachedTablesToUpdate = {
    "owned_vehicles"
  }
}
