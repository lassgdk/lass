return {settings = {
  graphics = {
    backgroundColor = {255,255,255},
  }
}, gameObjects = {
  {
    name = "Text Object",
    transform = {
      position = {
        x = 160,
        y = -112, --middle of the window
      },
      rotation = 0
    },
    components = {
      {
        script = "lass.builtins.graphics.TextRenderer",
        arguments = {
          text = "hello world!",
          box = require("lass.geometry").Rectangle(320, 100),
          align = "center",
          -- try activating some of the below lines...
          -- color = {100,100,0},
          -- fontSize = 24,
          -- shearFactor = {x = -1, y = 0}
        }
      },
    }
  },
}}
