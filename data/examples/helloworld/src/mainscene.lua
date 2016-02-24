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
          -- boxWidth = 320,
          box = require("lass.geometry").Rectangle(320, 100),
          align = "center",
          -- try activating some of the below lines...
          -- color = {100,100,0},
          -- fontSize = 24,
          -- shearFactor = {x = -1, y = 0}
        }
      },
      {
        script = "lass.builtins.animation.PeriodicInterpolator",
        arguments = {
          ifunction = "positiveX",
          targets = {{"gameObject", "transform", "rotation"}},
          amplitude = 360,
          sampleLength = 1,
          period = 2,
          autoplay = true
        }
      }
    }
  },
}}
