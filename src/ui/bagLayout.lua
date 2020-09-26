return function(margin, padding, direction, alignment, expand)
  margin = margin or 2
  padding = padding or 2
  local posKey, otherPosKey, sizeKey, otherSizeKey = 'x', 'y', 'w', 'h'
  if direction == 'vertical' then
    posKey, otherPosKey, sizeKey, otherSizeKey = 'y', 'x', 'h', 'w'
  end
  return function(control, children)
    local primarySize, otherSize = control[sizeKey], control[otherSizeKey]
    local current = margin
    local childrenSize = 0
    for i = 1, #children do
      local child = children[i]
      childrenSize = childrenSize + child[sizeKey] + padding
    end
    childrenSize = childrenSize - padding
    if alignment == 'center' or alignment == 'middle' then
      current = primarySize / 2 - childrenSize / 2
    elseif alignment == 'right' or alignment == 'bottom' then
      current = primarySize - childrenSize
    end
    for i = 1, #children do
      local child = children[i]
      child[posKey] = current
      if expand then
        child[otherPosKey] = margin
        child[otherSizeKey] = control[otherSizeKey] - margin * 2
      else
        child[otherPosKey] = otherSize / 2 - child[otherSizeKey] / 2
      end
      current = current + child[sizeKey] + padding
    end
  end
end
