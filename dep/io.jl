import EzXML
import Dates
import DataFrames

function read_xes(path)

    event_log_raw = EzXML.readxml(path)  # parse xml file
    ns = EzXML.namespace(event_log_raw.root)  # get namespace

    event_attributes_global = EzXML.findall(
        "./x:global[@scope='event']/*",
        ["x"=>ns]
        event_log_raw.root,
    )  # extract global event attributes

    event_classifiers = EzXML.findall(
        "./x:classifier",
        event_log_raw.root,
        ["x"=>ns]
    )  # extract event classifiers

    event_elements = unique(
        append!(
            [
                deepcopy(event_attributes_global[i]["key"])
                for i in 1:length(event_attributes_global)
                if haskey(event_attributes_global[i], "key")
            ],
            [
                i
                for j in 1:length(event_classifiers)
                for i in split(deepcopy(event_classifiers[j]["keys"]), " ")
                if haskey(event_classifiers[j], "keys")
            ]
        )
    )  # create list of event elements

    event_structure = Dict{String, Any}()
    for i in 1:length(event_elements)
        if occursin(":", event_elements[i])
            event_structure[
                match(
                    r":[a-zA-Z0-9]*",
                    event_elements[i]
                ).match[2:end]
            ] = String[]
        else
            event_structure[event_elements[i]] = String[]
        end
    end  # extract column structure for tabular data
    event_structure
    traces = EzXML.findall(
        "./x:trace",
        event_log_raw.root,
        ["x"=>ns]
    )  # extract traces

    event_log = Dict{String, Dict}()  # initialize event log

    # extract events from traces
    for child in traces
        curr_id = EzXML.findfirst(
            "./x:string[@key='concept:name']", child, ["x"=>ns]
        )["value"]  # use 'name' as id
        event_log[curr_id] = Dict{String, Any}()
        event_log[curr_id]["metadata"] = Dict{String, String}()
        for metadata in [
            elem
            for elem in EzXML.elements(child)
            if !(elem.name == "event")
        ]
            if (
                EzXML.haskey(metadata, "key")
                & EzXML.haskey(metadata, "value")
            )
                if occursin(":", metadata["key"])
                    key = match(
                        r":[a-zA-Z0-9]*",
                        metadata["key"]
                    ).match[2:end]
                else
                    key = deepcopy(metadata["key"])
                end
                event_log[curr_id]["metadata"][key] = deepcopy(
                    metadata["value"]
                )
            end
        end
        event_log[curr_id]["trace_complete"] = Dict[]
        for event in EzXML.findall("./x:event", child, ["x"=>ns])
            curr_event = Dict{String, String}()
            curr_event["case"] = curr_id
            for grandchild in EzXML.elements(event)
                if (
                    EzXML.haskey(grandchild, "key")
                    & EzXML.haskey(grandchild, "value")
                )
                    if occursin(":", grandchild["key"])
                        key = match(
                            r":[a-zA-Z0-9]*",
                            grandchild["key"]
                        ).match[2:end]
                    else
                        key = deepcopy(grandchild["key"])
                    end
                    curr_event[key] = deepcopy(grandchild["value"])
                end
            end
            push!(event_log[curr_id]["trace_complete"], deepcopy(curr_event))
        end
    end

    ids = deepcopy(collect(keys(event_log)))  # track case ids
    event_df = DataFrames.DataFrame(event_structure)  # initialize dataframe

    return event_log, ids

end

# path = joinpath("data", "Performance.xes")
# log = read_xes(path)

# NOTE: add streaming option for large files
