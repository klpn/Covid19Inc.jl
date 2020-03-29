module Covid19Inc

using Colors, CSV, DataFrames, Dates, PGFPlotsX
mainpath = normpath(@__DIR__, "..")
datapath = normpath(mainpath, "data")
plotdicts_all = [
    Dict(:num => :CasesFemale, :den => :PopFemale, :lab => "incidens (fall) kvinnor"),
    Dict(:num => :CasesMale, :den => :PopMale, :lab => "incidens (fall) män"),
    Dict(:num => :HospFemale, :den => :PopFemale, :lab => "incidens (sjukhus) kvinnor"),
    Dict(:num => :HospMale, :den => :PopMale, :lab => "incidens (sjukhus) män"),
    Dict(:num => :ICUFemale, :den => :PopFemale, :lab => "incidens (IVA) kvinnor"),
    Dict(:num => :ICUMale, :den => :PopMale, :lab => "incidens (IVA) män"),
    Dict(:num => :DeathsFemale, :den => :PopFemale, :lab => "mortalitet kvinnor"),
    Dict(:num => :DeathsMale, :den => :PopMale, :lab => "mortalitet män")
]
locs = Dict(
    56 => "Belgien", 208 => "Danmark", 380 => "Italien", 578 => "Norge",
    620 => "Portugal", 724 => "Spanien"
)

wpp2019 = CSV.File(normpath(datapath, "WPP2019_PopulationByAgeSex_Medium.csv")) |> DataFrame

ageaggrs = Dict(
    :i10o90 => DataFrame(AgeGrpStart = wpp2019[:AgeGrpStart][1:21],
        AgeGrp10Start = vcat(map(x->fld(x,10)*10, wpp2019[:AgeGrpStart][1:20]),90)),
    :i10o80 => DataFrame(AgeGrpStart = wpp2019[:AgeGrpStart][1:21],
        AgeGrp10Start = vcat(map(x->fld(x,10)*10, wpp2019[:AgeGrpStart][1:18]),fill(80,3)))
)

function ages10_loct(loc, ageaggr, t)
    inframe = ageaggrs[ageaggr]
    wpp_sub = wpp2019[(wpp2019[:LocID].==loc) .& (wpp2019[:Time].==t),
        [:AgeGrpStart, :PopMale, :PopFemale]]
    by(join(wpp_sub, inframe, on = :AgeGrpStart),
        :AgeGrp10Start,
        PopFemale = :PopFemale => x->(sum(x.*1000)),
        PopMale = :PopMale => x->(sum(x.*1000)))
end

function covid_pop(loc, ageaggr, enddate)
    covid = CSV.File(normpath(datapath, "$(loc)_covid19_$(enddate).csv")) |> DataFrame
    yr = Dates.year(Date(enddate))
    df = join(ages10_loct(loc, ageaggr, yr), covid, on = :AgeGrp10Start)
    Dict(:loc => loc, :enddate => enddate, :df => df)
end

lcd_save(lcd) =
    CSV.write(normpath(datapath, "$(lcd[:loc])_covid19_pop_$(lcd[:enddate]).csv"))

function lcd_load(loc, enddate)
    df = CSV.File("$(loc)_covid19_pop_$(enddate).csv") |> DataFrame
    Dict(:loc => loc, :enddate => enddate, :df => df)
end

function covidpl(lcd)
    df = lcd[:df]
    plotdicts = filter(pd->pd[:num] in names(df), plotdicts_all)
    p = @pgf Axis({ymode="log", xlabel="Ålder",
            title="COVID-19 $(locs[lcd[:loc]]) till $(lcd[:enddate])",
            legend_pos="outer north east", xmajorgrids, ymajorgrids, yminorgrids})
    ages = df[:AgeGrp10Start]
    plotcolors = distinguishable_colors(length(plotdicts)+1, [RGB(1,1,1)])[2:end]
    for (i, pd) in enumerate(plotdicts)
        rate = df[pd[:num]] ./ df[pd[:den]]
        @pgf push!(p, PlotInc({mark_options="solid", color=plotcolors[i]},
            Table([ages, rate])), LegendEntry(pd[:lab]))
    end
    p
end

end # module
