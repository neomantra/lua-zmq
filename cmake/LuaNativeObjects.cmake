#
# Lua Native Objects
#

set(LUA_NATIVE_OBJECTS_PATH ${CMAKE_SOURCE_DIR}/../LuaNativeObjects CACHE PATH
				"Directory to LuaNativeObjects bindings generator.")
set(USE_PRE_GENERATED_BINDINGS TRUE CACHE BOOL
				"Set this to FALSE to re-generate bindings using LuaNativeObjects")

macro(GenLuaNativeObjects _src_files_var)
	set(_new_src_files)
	foreach(_src_file ${${_src_files_var}})
		if(_src_file MATCHES ".nobj.lua")
			string(REGEX REPLACE ".nobj.lua" ".nobj.c" _src_file_out ${_src_file})
			string(REGEX REPLACE ".nobj.lua" ".nobj.ffi.lua" _ffi_file_out ${_src_file})
			add_custom_command(OUTPUT ${_src_file_out} ${_ffi_file_out}
				COMMAND lua ${LUA_NATIVE_OBJECTS_PATH}/native_objects.lua -outpath ${CMAKE_CURRENT_BINARY_DIR} -gen lua ${_src_file}
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				DEPENDS ${_src_file}
			)
			set_source_files_properties(${_src_file_out} PROPERTIES GENERATED TRUE)
			set_source_files_properties(${_ffi_file_out} PROPERTIES GENERATED TRUE)
			string(REGEX REPLACE ".nobj.lua" "" _doc_base ${_src_file})
			string(REGEX REPLACE ".nobj.lua" ".luadoc" _doc_file_out ${_src_file})
			add_custom_target(${_doc_file_out} ALL
				COMMAND lua ${LUA_NATIVE_OBJECTS_PATH}/native_objects.lua -outpath docs -gen luadoc ${_src_file}
				COMMAND luadoc -nofiles -d docs docs
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				DEPENDS ${_src_file}
			)
			set_source_files_properties(${_doc_file_out} PROPERTIES GENERATED TRUE)
			set(_new_src_files ${_new_src_files} ${_src_file_out})
		else(_src_file MATCHES ".nobj.lua")
			set(_new_src_files ${_new_src_files} ${_src_file})
		endif(_src_file MATCHES ".nobj.lua")
	endforeach(_src_file)
	set(${_src_files_var} ${_new_src_files})
endmacro(GenLuaNativeObjects _src_files_var)

