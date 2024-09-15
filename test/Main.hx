package test;

import gdoc.SVGGenerate;
import gdoc.NodeGraph2D;
import gdoc.NodeGraphReader;
import gdoc.NodeDoc;

class Main {
	static function main() {
		var doc = gdoc.VisioImport.loadAsGraphDoc("data/tests.vdx");

		trace('Doc');
		for (p in doc) {
			trace('Page ${p.name}');
			for (n in p.nodes) {
				trace('\tNode ${n.name} [${n.id}] parent ${n.parent} [${n.parentID}]');
				if (n.properties != null) {
					trace('\t\tProperties');
					for (kv in n.properties.keyValueIterator()) {
						trace('\t\t\tproperty ${kv.key} -> ${kv.value}');
					}
				}
				if (n.outgoing != null && n.outgoing.length > 0) {
					trace('\t\tConnections');
					for (c in n.outgoing) {
						trace('\t\t\tconnection \'${c.name}\' -> ${c.target} [${c.id}]');
                        if (c.properties != null) {
                            trace('\t\t\t\tProperties');
                            for (kv in c.properties.keyValueIterator()) {
                                trace('\t\t\t\t\tproperty ${kv.key} -> ${kv.value}');
                            }
                        }
					}
				}
			}
		}


        trace('Graph');
        var test1Graph = NodeGraphReader.fromDoc(doc, "test1");

        trace('\tPage test1');
        for (n in test1Graph.nodes) {
            trace('\t\tNode ${n.name}');
            trace('\t\t\tParent ${n.parent != null ? n.parent.name : "None"}');
            if (n.properties != null) {
                trace('\t\t\tProperties');
                for (kv in n.properties.keyValueIterator()) {
                    trace('\t\t\t\tproperty ${kv.key} -> ${kv.value}');
                }

                if (n.outgoing != null && n.outgoing.length > 0) {
					trace('\t\t\tOutgoing Connections');
					for (c in n.outgoing) {
						trace('\t\t\tconnection \'${c.name}\' -> ${c.target.name}');
                        if (c.properties != null) {
                            trace('\t\t\t\tProperties');
                            for (kv in c.properties.keyValueIterator()) {
                                trace('\t\t\t\t\tproperty ${kv.key} -> ${kv.value}');
                            }
                        }
					}
				}

                if (n.incoming != null && n.incoming.length > 0) {
					trace('\t\t\tIncoming Connections');
					for (c in n.incoming) {
						trace('\t\t\tconnection \'${c.name}\' -> ${c.target.name}');
                        if (c.properties != null) {
                            trace('\t\t\t\tProperties');
                            for (kv in c.properties.keyValueIterator()) {
                                trace('\t\t\t\t\tproperty ${kv.key} -> ${kv.value}');
                            }
                        }
					}
				}
            }
        }


        trace('SVG');
        var testSVGGraph = new NodeGraph2D();
        var n1 = testSVGGraph.addNode();
        n1.name = "Node 1";
        var n2 = testSVGGraph.addNode();
        n2.name = "Node 2";
        n2.x = 100;
        n2.y = 100;

        n1.connectTo(n2, "connection");
        
        SVGGenerate.writeNodeGraph2D("test.svg", testSVGGraph, (node, attr) -> {
            attr.fill = "lightgreen";
            attr.r = 10;
        });
	}
}
