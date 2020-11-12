Config.Modules.Status = {
  StatusMax          = 100,
  TickTime           = 1000,
  UpdateInterval     = 20,
  StatusIndex        = {"stress", "drunk", "drugs", "thirst", "hunger"},
  NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100},
  DefaultValues      = {0,0,0,100,100},
  StatusInfo         = {
    ["hunger"] = {
      color    = "orange",
      iconType = "fontawesome",
      icon     = "fa-hamburger",
      fadeType = "desc"
    },
    ["thirst"] = {
      color    = "cyan",
      iconType = "fontawesome",
      icon     = "fa-tint",
      fadeType = "desc"
    },
    ["drugs"] = {
      color    = "green",
      iconType = "fontawesome",
      icon     = "fa-cannabis",
      fadeType = "asc"
    },
    ["drunk"] = {
      color    = "purple",
      iconType = "fontawesome",
      icon     = "fa-glass-martini-alt",
      fadeType = "asc"
    },
    ["stress"] = {
      color    = "pink",
      iconType = "fontawesome",
      icon     = "fa-brain",
      fadeType = "asc"
    }
  }
}
