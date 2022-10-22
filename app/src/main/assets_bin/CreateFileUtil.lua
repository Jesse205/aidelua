local CreateFileUtil={}
--local ids
--local dia
local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)
local existsStr=getString(R.string.file_exists)
local LuaReservedCharacters = {"switch", "if", "then", "and", "break", "do", "else", "elseif", "end", "false", "for",
  "function", "in", "local", "nil", "not", "or", "repeat", "return", "true", "until", "while"} -- lua关键字



--根据文件名和扩展名获取用户真正想创建的文件路径
local function buildReallyFilePath(name,extensionName)
  if extensionName and not(name:find("%.[^/]*$")) then
    return name.."."..extensionName
  end
  return name
end

--创建文件
function CreateFileUtil.createFile(path,config)
  local file=File(path)
  local name=file.getName()
  local moduleName=name:match("(.+)%.") or name
  local shoredModuleName=(moduleName:match("/(.+)") or moduleName):gsub("%.","_"):gsub("%[",""):gsub("%]",""):gsub("%:","_")
  if table.find(LuaReservedCharacters,shoredModuleName) then
    shoredModuleName="_"..shoredModuleName
  end
  file.getParentFile().mkdirs()
  file.createNewFile()
  local fileContent=config.defaultContent:gsub("{{ShoredModuleName}}",shoredModuleName):gsub("{{ModuleName}}",moduleName)
  io.open(path,"w"):write(fileContent):close()
end

function CreateFileUtil.showCreateFileDialog(config,nowDir)--文件名填写对话框
  local builder
  local fileExtension=config.fileExtension
  builder=EditDialogBuilder(activity)
  :setTitle(formatResStr(R.string.project_create_withName,{config.name}))
  :setHint(R.string.file_name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local fileName=buildReallyFilePath(text,fileExtension)
    local filePath=rel2AbsPath(fileName,nowDir.getPath())
    local file=File(filePath)
    if file.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      CreateFileUtil.createFile(filePath,config)
      editLay.setErrorEnabled(false)
      showSnackBar(R.string.create_success)
    end,
    function(err)
      editLay
      .setError(err:match(".+throws.+Exception: (.-)\n") or err)
      .setErrorEnabled(true)
      showErrorDialog(R.string.create_failed,err)
      errorState=true
    end)
    FilesBrowserManager.refresh(nowDir)
    if errorState then
      return true--防止对话框关闭
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()

  local ids=builder.ids
  local edit,editLay=ids.edit,ids.editLay
  local lastErtor=false--如果在关闭错误之后立马设置帮助文字，就会导致帮助文字不显示。所以需要判断一下。

  editLay.setHelperText(formatResStr(R.string.file_viewName_content,{"."..fileExtension}))--设置初始显示的名字，因为刚进入时没有提示错误
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)--获取到的text是java类型的
      if text~="" then
        local fileName=File(buildReallyFilePath(text,fileExtension)).getName()
        if lastErtor then
          editLay
          .setHelperTextEnabled(false)
          .setHelperTextEnabled(true)
        end
        editLay.setHelperText(formatResStr(R.string.file_viewName_content,{fileName}))
        lastErtor=false
       else
        lastErtor=true
      end
    end
  })
end

function CreateFileUtil.showSelectTypeDialog(nowDir)--模版选择对话框
  local choice=activity.getSharedData("createfile_type")
  local nowDir=nowDir or FilesBrowserManager.directoryFile
  local names={}
  local templates={}
  for index,content in ipairs(FileTemplates) do
    local enabledVar=content.enabledVar
    if not(enabledVar) or _G[enabledVar] then
      table.insert(names,getLocalLangObj(content.name,content.enName))
      table.insert(templates,content)
      if choice==content.id then
        choice=table.size(templates)-1
      end
    end
  end
  if type(choice)~="number" then--类型不为数字类型说明没有找到真正的选项，设置为0
    choice=0
  end

  AlertDialog.Builder(activity)
  .setTitle(R.string.file_create)
  .setSingleChoiceItems(names,choice,{onClick=function(dialogInterface,index)
      choice=index
      activity.setSharedData("createfile_type",templates[index+1].id)
  end})
  .setPositiveButton(android.R.string.ok,function()
    local template=templates[choice+1]
    if template then
      CreateFileUtil.showCreateFileDialog(template,nowDir)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

return CreateFileUtil