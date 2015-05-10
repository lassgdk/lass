return {settings = {
  graphics = {
    backgroundColor = {255,255,255},
  }
}, gameObjects = {
  {
    name = "Text Object",
    transform = {
      position = {
        x = 0,
        y = -10,
      }
    },
    components = {
      {
        script = "lass.builtins.graphics.TextRenderer",
        arguments = {
          text = "hello world!",
          boxWidth = 320,
          align = "center",
          -- try activating some of the below lines...
          -- color = {100,100,0},
          -- fontSize = 24,
          -- offset = {x = 0, y = 100},
          -- shearFactor = {x = -1, y = 0}
        }
      }
    }
  },
}}
