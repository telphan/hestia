function dedup(array)
  local hash = {}
  local res = {}

  for _,v in ipairs(array) do
     if (not hash[v]) then
         table.insert(res, v)
         hash[v] = true
     end
  end	

  return res
end

return {
  dedup = dedup
}
