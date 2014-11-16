return {settings = {
  window = {
    width = 800,
    height = 600
  },
  graphics = {
    backgroundColor = {255,255,255},
    invertYAxis = true
  }
}, gameObjects = {
  {
    name = "Triangle",
    prefab = "triangleprefab",
    transform = {
      position = {
        x = 200,
        y = -300,
        z = 1
      },
      size = {
        x = .8,
        y = .8
      },
      rotation = 0,
    },
    children = {
      {
        name = "Satellite",
        prefab = "triangleprefab",
        transform = {
          position = {
            x = 200,
            z = 1
          },
          -- size = {
          --   x = .9,
          --   y = .9,
          -- }
        },
        prefabComponents = {
          {
            script = "lass.builtins.graphics.PolygonRenderer",
            arguments = {
              color = {200, 0, 80}
            }
          }
        },
        children = {
          {
            name = "SubSatellite",
            prefab = "triangleprefab",
            transform = {
              position = {
                x = 200,
                y = 0,
                z = 1
              },
              -- size = {
              --   x = .8
              -- }
            },
            prefabComponents = {
              {
                script = "lass.builtins.graphics.PolygonRenderer",
                arguments = {
                  color = {100, 200, 80}
                }
              }
            },
            children = {
              {
                name = "SubSubSatellite",
                prefab = "triangleprefab",
                transform = {
                  position = {
                    x = 200,
                    y = 0,
                    z = 1
                  }
                },
                prefabComponents = {
                  {
                    script = "lass.builtins.graphics.PolygonRenderer",
                    arguments = {
                      color = {200, 0, 80}
                    }
                  }
                },
              }
            }
          }
        }
      }
    }
  }
}}