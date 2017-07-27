# run from project directory

# use this line to test coverage
# include("test/rm_cov.jl");Pkg.test("PlanerTransformer",coverage=true)

cd("./src")
for (root, dirs, files) in walkdir(".")
  for file in files
    (a,b) = splitext(file)
    if b == ".cov"
      rm(file)
    end
  end
end
cd("..")

cd("./test")
for (root, dirs, files) in walkdir(".")
  for file in files
    (a,b) = splitext(file)
    if b == ".cov"
      rm(file)
    end
  end
end
cd("..")
