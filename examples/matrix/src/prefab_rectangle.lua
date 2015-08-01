local delay = require("lass.delay")

return {
  name = "Square",
  components = {
    {
      script = "lass.builtins.graphics.ShapeRenderer",
      arguments = {
        color = {20, delay(math.random, 90, 200), delay(math.random, 100, 255)},
        shape = {"Rectangle", 50, 50}
      }
    },
    {
      script = "lass.builtins.collision.Collider",
      arguments = {
        -- shape = {"Rectangle", 50, 50},
        shapeSource = {"gameObject", "getComponent", "lass.builtins.graphics.Renderer"},
        clickable = true,
        solid = false,
        layersToCheck = {}
      }
    },
    {
      script = "lass.builtins.input.MouseClickHandler",
      arguments = {
        targets = {
          {"gameObject", "getComponent", "lass.builtins.animation.PeriodicInterpolator", "play"},
          {"gameObject", "getComponent", "lass.builtins.audio.AudioSource", "source", "rewind"},
          {"gameObject", "getComponent", "lass.builtins.audio.AudioSource", "source", "play"},
        },
        conditions = {
          event = "mousepressed",
          button = "l",
          clickedOnSelf = true,
        },
        targetArguments = {{0}}
      }
    },

    {
      script = "lass.builtins.animation.PeriodicInterpolator",
      arguments = {
        ifunction = "sine",
        targets = {
          {"gameObject", "transform", "size", "x"},
          {"gameObject", "transform", "size", "y"}
        },
        amplitude = .2,
        period = .4,
        autoplay = false
      }
    },
    -- {
    --   script = "lass.builtins.animation.PeriodicInterpolator",
    --   arguments = {
    --     ifunction = "positiveX",
    --     targets = {{"gameObject", "transform", "rotation"}},
    --     sampleLength = 360,
    --     period = 4,
    --     autoplay = true
    --   }
    -- },
    {
      script = "lass.builtins.audio.AudioSource",
      arguments = {
        filename = delay(require("lass.collections").random, {
          "matrix_e_fl.ogg",
          "matrix_b_fl.ogg",
          "matrix_g.ogg",
          "matrix_f.ogg",
          "matrix_c.ogg",
        }),
        sourceType = "static",
        autoplay = false,
      }
    }
  }
}
