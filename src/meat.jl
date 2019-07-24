function shake(package)
    # raw snooping 
    name = randstring(12)

    call = """
    SnoopCompile.@snoopc "/tmp/$name.log" begin
        using Pkg, $package
        Pkg.build("$package")
        include(joinpath(dirname(dirname(pathof($package))), "test", "runtests.jl"))
    end    
    """;
    println("Snooping tests/build for $package...")
    eval(Meta.parse(call));

    # process snooping 
    data = SnoopCompile.read("/tmp/$name.log");
    pc = SnoopCompile.parcel(reverse!(data[2]));
    rm("/tmp/$name.log")

    # construct deps sets
    println("Diffing dependencies...")
    used = [String(key) for key in keys(pc)]; 
    ctx = Pkg.Types.Context()
    pkg_ctx = ctx.env.manifest[ctx.env.project.deps[package]]
    listed = keys(pkg_ctx.deps)

    # filtering step, just to reduce false positives 
    lowHangingFruit = setdiff(listed, used)
    println("Filtering...")
    filter!(fruit -> ~any(occursin.(Ref(fruit), data[2])), lowHangingFruit)

    println("These project deps are unused in tests:")
    return lowHangingFruit
end
