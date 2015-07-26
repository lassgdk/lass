return {settings = {
  --settings for this scene go here
}, gameObjects = {
    {
    name = "Tile Map",
    transform = {
      position = {
        x = 280,
        y = -150,
        z = 0
      },
      rotation = 0
    },
    components = {
      {
        script = "lass.builtins.tilemap.TileMap",
        arguments = {
          map = {
            {1,1,1,1,1},
            {1,1,1,1,1},
            {1,1,1,1,1},
            {1,1,1,1,1},
            {1,1,1,1,1},
          },
          tileSize = {
            x = 60,
            y = 60
          },
          tiles = {
            "prefab_rectangle.lua"
          }
        }
      },
      -- {
      --   script = "lass.builtins.audio.AudioSource",
      --   arguments = {
      --     filename = "lass.mp3",
      --     sourceType = "stream",
      --     autoplay = true,
      --   }
      -- }
    }
  },
}}
