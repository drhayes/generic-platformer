return function(margin)
  margin = margin or 2
  return function(control, children)
    local w, h = control.w - margin * 2, control.h - margin * 2
    for i = 1, #children do
      local child = children[i]
      child.x, child.y = margin, margin
      child.w, child.h = w, h
    end
  end
end
