return {settings = {
  window = {
    width = 960,
    height = 600
  },
  graphics = {
    backgroundColor = {20,20,20},
    invertYAxis = true
  }
}, gameObjects = {
  {
    name = "Triangle",
    prefab = "triangleprefab.lua",
    transform = {
      position = {
        x = 180,
        y = -300,
        z = 1
      },
      size = {
        x = 1,
        y = 1
      },
      rotation = 0,
    },
    prefabComponents = {
      {
        script = "PlayerInput",
        arguments = {
          resizeAmount = .1
        }
      }
    },
    children = {
      {
        name = "Satellite",
        prefab = "triangleprefab.lua",
        transform = {
          position = {
            x = 210,
            z = 1
          },
          size = {x=.9, y=.9}
        },
        prefabComponents = {
          {
            script = "lass.builtins.graphics.PolygonRenderer",
            arguments = {
              color = {192, 0, 116}
            }
          },
        },
        children = {
          {
            name = "SubSatellite",
            prefab = "triangleprefab.lua",
            transform = {
              position = {
                x = 210,
                y = 0,
                z = 1
              },
              size = {x=.9, y=.9}
            },
            prefabComponents = {
              {
                script = "lass.builtins.graphics.PolygonRenderer",
                arguments = {
                  color = {157, 228, 0}
                }
              }
            },
            children = {
              {
                name = "SubSubSatellite",
                prefab = "triangleprefab.lua",
                transform = {
                  position = {
                    x = 210,
                    y = 0,
                    z = 1
                  },
                  size = {x=.9, y=.9}
                },
                prefabComponents = {
                  {
                    script = "lass.builtins.graphics.PolygonRenderer",
                    arguments = {
                      color = {244, 148, 0}
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  {
    name = "Scene Manager",
    transform = {
      position = {
        x = 480,
        y = -525,
        z = 0
      },
    },
    components = {
      {
        script = "lass.builtins.graphics.TextRenderer",
        arguments = {
          color = {240,240,240},
          boxWidth = 940,
          align = "right",
          text = "click on a triangle to start/stop rotation\n(left button CCW, right button CW)\nzoom in and out with scrollwheel"
        }
      }
    }
  }
}}