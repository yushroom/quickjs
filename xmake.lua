-- set_project("quickjs")

add_rules("mode.debug", "mode.release")
add_defines("CONFIG_VERSION=\"2021-03-27\"")
set_group("quickjs")
-- set_languages("c99")

-- if is_plat("windows") then 
--     add_defines("CONFIG_WIN32=\"y\"")
-- end 

option("CONFIG_BIGNUM")
    set_default(false)
    set_showmenu(true)
    add_defines("CONFIG_BIGNUM")

target("quickjs")
    set_kind("static")
    add_includedirs(".", {public=true})
    add_headerfiles(
        "cutils.h",
        "libunicode.h",
        "list.h",
        "quickjs-atom.h",
        "quickjs-libc.h",
        "quickjs-opcode.h",
        "quickjs.h")
    add_files(
        "cutils.c",
        "libunicode.c",
        "quickjs-libc.c",
        "quickjs.c")

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
        add_defines("CONFIG_BIGNUM", {public=true})
    end

target("qjsc")
    set_kind("binary")
    add_files("qjsc.c")
    add_deps("quickjs")

    add_headerfiles("getopt.h")
    add_files("getopt.c")

rule("js")
    set_extensions(".js")
    on_buildcmd_file(function (target, batchcmds, sourcefile_js, opt)
        import("core.project.depend")
		import("utils.progress")
        local qjsc = target:dep("qjsc"):targetfile()
        --print(qjsc)
        assert(os.exists(qjsc), "error: qjsc not found!")
        local js_c = path.join(target:autogendir(), "rules", "js_c", path.basename(sourcefile_js) .. ".c")
        local objectfile = target:objectfile(js_c)
        table.insert(target:objectfiles(), objectfile)
        --print(js_c, objectfile)

        -- add commands
        batchcmds:show_progress(opt.progress, "${color.build.object} compiling.js %s", sourcefile_js)
        batchcmds:mkdir(path.directory(js_c))
        batchcmds:vrunv(qjsc, {"-c", "-o", js_c, "-m", sourcefile_js})
        batchcmds:compile(js_c, objectfile)

        -- add deps
        batchcmds:add_depfiles(sourcefile_js)
        local dependfile = target:dependfile(objectfile)
        batchcmds:set_depmtime(os.mtime(dependfile))
        batchcmds:set_depcache(dependfile)
    end)

target("qjs")
    set_policy("build.across_targets_in_parallel", false)
    set_kind("binary")
    add_files("qjs.c")
    add_deps("quickjs")
    add_deps("qjsc")
    add_rules("js")
    add_files("repl.js")

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