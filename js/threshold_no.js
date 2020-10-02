

        // Inspired by https://bl.ocks.org/gordlea/27370d1eea8464b04538e6d8ced39e89
        // and https://www.d3-graph-gallery.com/graph/line_change_data.html
        // and https://bl.ocks.org/jadiehm/0d341b74bef30889c893a3b14cbeb974
        // and https://bl.ocks.org/dimitardanailov/99950eee511375b97de749b597147d19

        svg = d3.select("#svg0")

        var width = +svg.attr("width"),
            height = +svg.attr("height"),
            activeClassName = 'active-d3-item';


        svg_no = d3.select("#svg-no")

        console.log("hello")




        d3.json("../processed_data/foo4.json", function(error, dict) {

            if (error) throw error;

            console.log(dict)

            d3.json("../processed_data/foo4_noiseOnly.json", function(error, dict_no) {

                if (error) throw error;

                console.log(dict_no)
                    
                

                const models = Object.keys(dict)
                console.log(models)
                console.log("hello")

                let model = "cosineGeometric"
                console.log(dict[model])


                // Pick one threshold and draw on the svg
                let threshold_vals = Object.keys(dict[model])
                let n_threshold_vals = threshold_vals.length
                console.log(n_threshold_vals)
                

                // Set x and y scales
                let x_scale = d3.scaleLinear()
                    .domain([0, 1])
                    .range([100, 500]);

                
                let y_scale = d3.scaleLinear().range([500,100]);
                let yAxis = d3.axisLeft().scale(y_scale);

                let y_scale_no = d3.scaleLinear().range([500,100]);
                let yAxis_no = d3.axisLeft().scale(y_scale_no);
                svg.append("g")
                    .attr("class","myYaxis")
                    .attr("transform", `translate(100,0)`);

                svg_no.append("g")
                    .attr("class","myYaxis_no")
                    .attr("transform", "translate(100,0)");

                // Draw axis labels
                let margin = 40;
                svg.append("text") 
                    .attr("class","axis-title")            
                    .attr("transform",
                            "translate(" + (width/2) + " ," + 
                                        (height - margin) + ")")
                    .style("text-anchor", "middle")
                    .text("Edge density");

                svg.append("text") 
                    .attr("class","axis-title")            
                    .attr("transform",
                            "translate(" + (margin) + " ," + 
                                        (height/2) + ")")
                    .style("text-anchor", "middle")
                    .text("Betti_k");

                svg_no.append("text") 
                    .attr("class","axis-title")            
                    .attr("transform",
                            "translate(" + (width/2) + " ," + 
                                        (height - margin) + ")")
                    .style("text-anchor", "middle")
                    .text("Edge density");

                svg_no.append("text") 
                    .attr("class","axis-title")            
                    .attr("transform",
                            "translate(" + (margin) + " ," + 
                                        (height/2) + ")")
                    .style("text-anchor", "middle")
                    .text("Betti_k");

                
                // Draw line graph
                let line = d3.line()
                    .x(function(d, i) {return x_scale(i); }) // set the x values for the line generator
                    .y(function(d) {return y_scale(d); }) // set the y values for the line generator 
                    .curve(d3.curveMonotoneX) // apply smoothing to the line

                

                // Draw axes
                svg.append("g")
                    .attr("class", "xaxis")
                    .attr("transform", `translate(0,${height-100})`)
                    .call(d3.axisBottom(x_scale));

                svg_no.append("g")
                    .attr("class", "xaxis")
                    .attr("transform", `translate(0,${height-100})`)
                    .call(d3.axisBottom(x_scale));

                


                // Draw data
                const betti_colors = ["blue", "green", "red", "pink"];
                const nEdges = 2415;

                const update_threshold_plot = (data, data_no, threshold_edge) => {


                    //////////// FINISH ADJUSTING y_scale. make y_scale_no
                    let max_y = d3.max([d3.max(data.dim1), d3.max(data.dim2), d3.max(data.dim3), d3.max(data.dim4)]);
                    let max_y_no = d3.max([d3.max(data_no.dim1), d3.max(data_no.dim2), d3.max(data_no.dim3), d3.max(data_no.dim4)]);
                    console.log(max_y)
                    let buffer = max_y*(0.4)
                    let buffer_no = max_y_no*(0.4)

                    
                    y_scale.domain([0, max_y+buffer]);
                    y_scale_no.domain([0, max_y_no+buffer_no]);

                    svg.selectAll(".myYaxis")
                        .transition()
                        .duration(1000)
                        .call(yAxis);

                    svg_no.selectAll(".myYaxis_no")
                        .transition()
                        .duration(1000)
                        .call(yAxis_no);


                    let area = function(dimn) {
                        
                        return d3.area()
                        .x(function(d, i) {return x_scale(i/nEdges); }) 
                        .y0(function(d,i) {
                            return ((data[`dim${dimn}`][i] - d > 0) ? y_scale(data[`dim${dimn}`][i] - d) : y_scale(0)); })
                        .y1(function(d,i) { return y_scale(data[`dim${dimn}`][i] + d); }); 
                    };

                    let area_no = function(dimn) {
                        
                        return d3.area()
                        .x(function(d, i) {return x_scale(i/nEdges); }) 
                        .y0(function(d,i) {
                            return ((data_no[`dim${dimn}`][i] - d > 0) ? y_scale_no(data_no[`dim${dimn}`][i] - d) : y_scale_no(0)); })
                        .y1(function(d,i) { return y_scale_no(data_no[`dim${dimn}`][i] + d); }); 
                    };

                

                    let lines = {line1: svg.selectAll(".dim1").data([data.dim1]),
                        line2: svg.selectAll(".dim2").data([data.dim2]),
                        line3: svg.selectAll(".dim3").data([data.dim3]),
                        line4: svg.selectAll(".dim4").data([data.dim4])};

                    let std_areas = {std1: svg.selectAll(".std1").data([data.std1]),
                        std2: svg.selectAll(".std2").data([data.std2]),
                        std3: svg.selectAll(".std3").data([data.std3]),
                        std4: svg.selectAll(".std4").data([data.std4])};

                    let lines_no = {line1: svg_no.selectAll(".dim1_no").data([data_no.dim1]),
                        line2: svg_no.selectAll(".dim2_no").data([data_no.dim2]),
                        line3: svg_no.selectAll(".dim3_no").data([data_no.dim3]),
                        line4: svg_no.selectAll(".dim4_no").data([data_no.dim4])};

                    let std_areas_no = {std1: svg_no.selectAll(".std1_no").data([data_no.std1]),
                        std2: svg_no.selectAll(".std2_no").data([data_no.std2]),
                        std3: svg_no.selectAll(".std3_no").data([data_no.std3]),
                        std4: svg_no.selectAll(".std4_no").data([data_no.std4])};


                    for (let index = 0; index < 4; index++) {


                        lines[`line${index+1}`].enter()
                            .append("path")
                                .attr("class","dims")
                                .attr("class",`dim${index+1}`)
                                .merge(d3.selectAll(`.dim${index+1}`))
                                .transition()
                                .duration(1000)
                                .attr("d", d3.line()
                                    .x(function(d, i) {return x_scale(i/nEdges); })
                                    .y(function(d) {return y_scale(d); }))
                                .attr("stroke", betti_colors[index])
                                .attr("fill", "none")
                                .attr("stroke-width", 3);


                        
                        std_areas[`std${index+1}`].enter()
                            .append("path")
                            .attr("class","stds")
                            .attr("class",`std${index+1}`)
                            .merge(d3.selectAll(`.std${index+1}`))
                            .transition()
                            .duration(1000)
                            .attr("d",area(index+1))
                            .attr("opacity", 0.2)
                            .attr("fill", betti_colors[index])


                        lines_no[`line${index+1}`].enter()
                            .append("path")
                                .attr("class","dims")
                                .attr("class",`dim${index+1}_no`)
                                .merge(d3.selectAll(`.dim${index+1}_no`))
                                .transition()
                                .duration(1000)
                                .attr("d", d3.line()
                                    .x(function(d, i) {return x_scale(i/nEdges); })
                                    .y(function(d) {return y_scale_no(d); }))
                                .attr("stroke", betti_colors[index])
                                .attr("fill", "none")
                                .attr("stroke-width", 3);


                        
                        std_areas_no[`std${index+1}`].enter()
                            .append("path")
                            .attr("class","stds")
                            .attr("class",`std${index+1}_no`)
                            .merge(d3.selectAll(`.std${index+1}_no`))
                            .transition()
                            .duration(1000)
                            .attr("d",area_no(index+1))
                            .attr("opacity", 0.2)
                            .attr("fill", betti_colors[index])
                    }


                

                    let threshold_line = svg.selectAll(".threshline").data([threshold_edge]);
                    threshold_line.enter()
                        .append("path")
                        .attr("class", "threshline")
                        .merge(d3.selectAll(".threshline"))
                        .transition()
                        .duration(1000)
                        .attr("d", function(d) {console.log(d); return `M ${x_scale(d/nEdges)} ${y_scale(0)} L ${x_scale(d/nEdges)} ${y_scale(max_y+buffer)}`})
                        .attr("stroke", "black")
                        .attr("stroke-width", 2);




                
                };

                let edge_num = 242
                let value_edge = 1
                
                update_threshold_plot(dict[model][edge_num],dict_no[model][edge_num], edge_num);


                let changed = function() {
                    value_edge = this.value;
                    console.log(value_edge);
                    console.log(model)
                    edge_num = Number(threshold_vals[value_edge]);
                    update_threshold_plot(dict[model][edge_num], dict_no[model][edge_num], edge_num);

                };

                let next_button = function() {
                    if (value_edge < (n_threshold_vals-1)) {
                        value_edge++
                    }
                    console.log(value_edge);
                    console.log(model)
                    edge_num = Number(threshold_vals[value_edge]);
                    update_threshold_plot(dict[model][edge_num],dict_no[model][edge_num], edge_num);

                };

                let back_button = function() {
                    if (value_edge > 0) {
                        value_edge--
                    }
                    console.log(value_edge);
                    console.log(model)
                    edge_num = Number(threshold_vals[value_edge]);
                    update_threshold_plot(dict[model][edge_num],dict_no[model][edge_num], edge_num);

            };


                const dropdownChange = function() {
                    model = this.value;
                    console.log(model)
                    console.log(edge_num)

                    update_threshold_plot(dict[model][edge_num],dict_no[model][edge_num], edge_num);
                    
                };





                d3.select("input")
                    .on("input", changed)
                    .on("change", changed);


                
                var dropdown = d3.select("#dropdown")
                    .insert("select", "svg")
                    .on("change", dropdownChange);

                dropdown.selectAll("option")
                    .data(models)
                    .enter().append("option")
                    .attr("value", function (d) { return d; })
                    .text(function (d) {
                        return d[0].toUpperCase() + d.slice(1,d.length); // capitalize 1st letter
                    });

                d3.select("#next-button")
                    .on("click",next_button)

                d3.select("#back-button")
                    .on("click",back_button)




            })
        })

       