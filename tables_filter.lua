-- see Quarto discussion (https://github.com/quarto-dev/quarto-cli/discussions/849)

-- is the table a simple array?
-- see: https://web.archive.org/web/20140227143701/http://ericjmritz.name/2014/02/26/lua-is_array/
function tisarray(t)
  local i = 0
  for _ in pairs(t) do
      i = i + 1
      if t[i] == nil then return false end
  end
  return true
end

-- https://stackoverflow.com/a/7615129
local function mysplit (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end -- note that in this function, .foo.bar splits the same as foo.bar

-- this won't match { .classes } or {.class1 .class2}
-- it only matches {.class}, {.class1.class2}, etc. NO spaces!
function Table(tbl)
  local function find_text_content(node)
    if node == nil then
        return nil
    end
    if node.t == "Plain" then
      return node.content
    end
    if node.t == "Para" then
      return node.content
    end
    if tisarray(node) then
      return find_text_content(node[1])
    end
    if node.t == "BlockQuote" then
      return find_text_content(node.content[1])
    end
    if node.t == "CodeBlock" then
      return node.content
    end
    if node.t == "Header" then
      return node.content
    end
    if node.t == "HorizontalRule" then
      return nil
    end
    if node.t == "LineBreak" then
      return nil
    end
    if node.t == "Null" then
      return nil
    end
    if node.t == "Space" then
      return nil
    end
    if node.t == "Str" then
      return node.text
    end
    if node.t == "Emph" then
      return find_text_content(node.content[1])
    end
    if node.t == "Strong" then
      return find_text_content(node.content[1])
    end
    if node.t == "Strikeout" then
      return find_text_content(node.content[1])
    end
    if node.t == "Superscript" then
      return find_text_content(node.content[1])
    end
    if node.t == "Subscript" then
      return find_text_content(node.content[1])
    end
    if node.t == "SmallCaps" then
      return find_text_content(node.content[1])
    end
    if node.t == "Quoted" then
      return find_text_content(node.content[1])
    end
    if node.t == "Cite" then
      return find_text_content(node.content[1])
    end
    if node.t == "Code" then
      return node.text
    end
    if node.t == "Math" then
      return node.text
    end
    if node.t == "RawInline" then
      return node.text
    end
    if node.t == "Link" then
      return nil
    end
    if node.t == "Image" then
      return find_text_content(node.content[1])
    end
    if node.t == "Note" then
      return find_text_content(node.content[1])
    end
    if node.t == "Span" then
      return find_text_content(node.content[1])
    end
    if node.t == "RawBlock" then
      return node.text
    end
    if node.t == "Div" then
      return find_text_content(node.content[1])
    end
    if node.t == "BulletList" then
      return find_text_content(node.content[1])
    end
    if node.t == "OrderedList" then
      return find_text_content(node.content[1])
    end
    if node.t == "DefinitionList" then
      return find_text_content(node.content[1])
    end
    if node.t == "Table" then
      -- FIXME
      return nil
    end
    if node.t == "SimpleTable" then
      -- FIXME
      return nil
    end
    error("Unknown node type: " .. node.t)
    return nil
  end

  if tbl.caption ~= nil then
    local m = nil
    local which = nil
    if tbl.caption.long ~= nil then
      which = find_text_content(tbl.caption.long)
      if which == nil then
        return nil
      end
    elseif tbl.caption.short ~= nil then
      -- this won't match { .classes } or {.class1 .class2}
      -- it only matches {.class}, {.class1.class2}, etc. NO spaces!
      which = find_text_content(tbl.caption.short)
      if which == nil then
        return nil
      end
    end
    if which == nil then
      return nil
    end
    m = string.match(which[1].text, "{%.(.+)}")
    if m ~= nil then
      for _, class in ipairs(mysplit(m, ".")) do
        table.insert(tbl.classes, class)
      end
      table.move(which, 2, #which, 1)
      return tbl
    end
  end
end