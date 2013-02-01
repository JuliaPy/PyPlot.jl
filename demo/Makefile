SRC = 1-plot.jl 2-subplot.jl 3-plotfile.jl 4-control-details.jl

README.md: $(SRC) 5-more.md
	echo > README.md
	echo "# demo" > README.md
	echo >> README.md
	$(foreach file,$(SRC), \
		echo "## $(file)" >> README.md; \
		echo >> README.md; \
		echo '```julia' >> README.md; \
		tail -n+7 ${file} >> README.md; \
		echo '```' >> README.md; \
		echo >> README.md; \
		echo "[$(subst jl,png,${file})]($(subst jl,png,${file}))" >> README.md; \
		echo >> README.md; \
		)
	cat 5-more.md >> README.md
