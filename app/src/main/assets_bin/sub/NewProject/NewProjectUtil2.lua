--主要给在线程里面使用
local NewProjectUtil2={}
local TEMPLATES_DIR_PATH=activity.getLuaDir("../../templates")--模板路径
local PRJS_PATH=getSharedData("projectsDir")--项目路径

NewProjectUtil2.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil2.PRJS_PATH=PRJS_PATH

--格式化信息用的，必须在线程内使用，且必须设置metatable
local tableConfigFormatter={
  defaultImport=function(content) -- import "%s"
    return "\nimport \""..table.concat(content,"\"\nimport \"").."\"\n"
  end,
  includeLua=function(content) -- config.lua中的
    return "\""..table.concat(content,"\",\"").."\","
  end,
}
NewProjectUtil2.tableConfigFormatter=tableConfigFormatter


function NewProjectUtil2.buildKeyItem(key,content)
  local text
  if type(content)=="table" then
    if #content=="" then
      text=tableConfigFormatter[key](content)
     else
      text=""
    end
   else
    text=tostring(content)
  end
  return text
end

function NewProjectUtil2.readConfig(path,basePath)
  return getConfigFromFile(basePath.."/"..path)
end

function NewProjectUtil2.unzip(path,unzipPath)
  File(unzipPath).mkdirs()
  local zipFile=ZipFile(path)
  if zipFile.isValidZipFile() then
    zipFile.extractAll(unzipPath)
    return true
   else
    --print("损坏的压缩包:",path)
    return false
  end
end
return NewProjectUtil2
