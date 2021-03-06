# Covid19Inc.jl

There seems to be some interesting interactions between age and sex
for various outcomes related to COVID-19 infection, e.g. the
ratio between male and female incidence in (confirmed) infection
may increase with age. At the same time, available data which break
down the number of cases on both sex and age are still relatively
sparse.

This repository collects age- and sex-specific data on COVID-19
infection from various locations around the world in CSV files
in the [`data`](https://github.com/klpn/Covid19Inc.jl/blob/master/data) directory.
The files are named according to the scheme `[WPP location]_covid19_[date].csv`,
e.g. [data/380_covid19_2020-03-26.csv](https://github.com/klpn/Covid19Inc.jl/blob/master/data/380_covid19_2020-03-26.csv)
contains data for Italy (WPP location 380) up to 2020-03-26.
Sources for the data are given in the
BibTeX file [`data/sources.bib`](https://github.com/klpn/Covid19Inc.jl/blob/master/data/sources.bib).

Note that the confirmed cases are only a fraction of all those
infected, and, for many locations, might be seen as reflecting the
incidence in COVID-19 with relatively severe symptoms. Also, the
ratios between ages and sexes may be biased because of the infection
initially entering a certain segment of the population. For example,
the data for Denmark (location 208) contains four columns with
incident cases, where `CasesFemale` and `CasesMale` contain the
cumulative number of cases since February, and `CasesFemale2` and
`CasesMale2` contain the number of cases since 2020-03-12, when
Denmark entered a second phase, where only those with symptons
requiring hospitalization are tested
([SSI](https://www.ssi.dk/aktuelt/sygdomsudbrud/coronavirus/covid-19-i-danmark-epidemiologisk-overvaagningsrapport)). For later Danish reports, where the cases since 2020-03-12 predominant, `CasesFemale1` and `CasesMale1` contain the cases before that date.
As can be seen, the sex ratios for some age groups differ between the
different phases.

The repository also provides a Julia module for plotting incidence by
age and sex, using the [PGFPlotsX.jl](https://github.com/KristofferC/PGFPlotsX.jl)
package. In order to provide
estimates of population at risk, the module uses World Population
Prospects for 2019. You can download the 
[WPP 2019 CSV file](https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2019_PopulationByAgeSex_Medium.csv) in the `data` directory.

In order to plot incidence for Spain, with
10-year age group up to 90– years, run from Julia.

```julia
include("src/Covid19Inc.jl")
Covid19Inc.covid_pop(724, :i10o90, "2020-03-30") |> Covid19Inc.covidpl
```


