set_project("quickjs")

add_rules("mode.debug", "mode.release")
add_defines("CONFIG_VERSION=\"2021-03-27\"")

-- if is_plat("windows") then 
--     add_defines("CONFIG_WIN32=\"y\"")
-- end 

option("CONFIG_BIGNUM")
    set_default(false)
    set_showmenu(true)
    add_defines("CONFIG_BIGNUM")

target("quickjs")
    set_kind("static")
    add_headerfiles("cutils.h")
    add_headerfiles("libunicode.h")
    add_headerfiles("list.h")
    add_headerfiles("quickjs-atom.h")
    add_headerfiles("quickjs-libc.h")
    add_headerfiles("quickjs-opcode.h")
    add_headerfiles("quickjs.h")
    add_files("cutils.c")
    add_files("libunicode.c")
    add_files("quickjs-libc.c")
    add_files("quickjs.c")

    add_headerfiles("libregexp.h")
    add_files("libregexp.c")

    if is_plat("windows") then
        add_headerfiles("sys_time.h")
        add_files("gettimeofday.c")
        add_defines("_GNU_SOURCE")
        add_defines("EMSCRIPTEN")
    else
        add_headerfiles("libbf.h")
        add_files("libbf.c")
    end

target("qjsc")
    set_kind("binary")
    add_files("qjsc.c")
    add_deps("quickjs")

    add_headerfiles("getopt.h")
    add_files("getopt.c")

target("reql")
    set_kind("static")
    add_files("repl.c")
    add_deps("quickjs")
    add_deps("qjsc")
    -- before_build_file(function (target,sourcefile,opt) 
    --     -- os.run("$(buildir)/qjsc -c -o $(target:targetdir())/repl.c -m $(projectdir)/quickjs/repl.js")
    --     -- os.run(path.join(target:targetdir(),"./qjsc.exe"),"")
    --     import("core.project.depend")
    --     depend.on_changed(function()
    --         os.vrunv('qjsc.exe', {"-c", "-o", "repl.c", "-m", "repl.js"})
    --     end, {files = sourcefile})
    -- end)

target("qjs")
    set_kind("binary")
    if not is_plat("windows") then
        add_options("CONFIG_BIGNUM")
    end
    add_files("qjs.c")
    add_deps("quickjs")
    add_deps("qjsc")
    add_deps("reql")

if not is_plat("windows") then
    target("run-test262")
        set_kind("binary")
        add_files("run-test262.c")
        add_deps("quickjs")
end

target("unicode_gen")
    set_kind("binary")
    add_files("unicode_gen.c")
    add_deps("quickjs")