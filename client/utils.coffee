
S4 = ->
  (((1 + Math.random()) * 65536) | 0).toString(16).substring(1)

utils = NS "FLIPS.utils"

utils.guidGenerator = ->
  (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())

