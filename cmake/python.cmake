find_package(Python COMPONENTS Interpreter)

execute_process(COMMAND ${Python_EXECUTABLE} -c "import gemini3d.model"
  RESULT_VARIABLE e)
if(e EQUAL 0)
  set(py_ok true CACHE BOOL "PyGemini detected.")
else()
  message(WARNING "PyGemini is not setup: https://github.com/gemini3d/pygemini")
endif()
