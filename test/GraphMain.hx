package test;

import haxe.Int64;
import gdoc.FaceMesh3D.FaceMesh3DFace;
import seedyrng.Seedy;
import seedyrng.Random;
import gdoc.SVGGenerate;
import gdoc.NodeGraph;
import gdoc.NodeGraphReader;
import gdoc.NodeDoc;

import gdoc.GraphRewriter;
import gdoc.NodeGraphPrinter;
import gdoc.HalfEdgeMesh;
import gdoc.QuickHull3D;
import gdoc.Point3D;
import gdoc.Point2D;
import gdoc.PowerDiagram;
import gdoc.WeightedPoint2D;

using Lambda;

class GraphMain {
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
			var n_parent = n.getParent();
			trace('\t\t\tParent ${n_parent != null ? n_parent.name : "None"}');
			if (n.properties != null) {
				trace('\t\t\tProperties');
				for (kv in n.properties.keyValueIterator()) {
					trace('\t\t\t\tproperty ${kv.key} -> ${kv.value}');
				}

				var n_outgoing = n.getOutgoingEdges().array();
				if (n_outgoing != null && n_outgoing.length > 0) {
					trace('\t\t\tOutgoing Connections');
					for (c in n_outgoing) {
						trace('\t\t\tconnection \'${c.name}\' -> ${c.target.name}');
						if (c.properties != null) {
							trace('\t\t\t\tProperties');
							for (kv in c.properties.keyValueIterator()) {
								trace('\t\t\t\t\tproperty ${kv.key} -> ${kv.value}');
							}
						}
					}
				}

				var n_incoming = n.getIncomingEdges().array();
				if (n_incoming != null && n_incoming.length > 0) {
					trace('\t\t\tIncoming Connections');
					for (c in n_incoming) {
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

		{
			trace('SVG');
			var testSVGGraph = new NodeGraph();
			var n1 = testSVGGraph.addNode();
			n1.name = "Node 1";
			var n2 = testSVGGraph.addNode();
			n2.name = "Node 2";
			n2.x = 100;
			n2.y = 100;

			testSVGGraph.connectNodes(n1, n2, "connection");

			SVGGenerate.writeNodeGraph("test.svg", testSVGGraph, (node, attr) -> {
				attr.fill = "lightgreen";
				attr.r = 10;
			});
		}

		/// rewrite test
		{
			var rewriteGraph = new NodeGraph();
			var startNode = rewriteGraph.addNode();
            startNode.name = "Start";
            var endNode = rewriteGraph.addNode();
            endNode.name = "End";
            rewriteGraph.connectNodes(startNode, endNode, "first");

            trace('Initial Graph');
            trace(NodeGraphPrinter.graphToString(rewriteGraph));

			var rules = [
				new Rule([new EdgePattern([], DirAny)], new OpSplitEdge(new MetaEdge(MStrLiteral("incoming")), new MetaEdge(MStrLiteral("outgoing")), new MetaNode(MStrLiteral("split")))),
                new Rule([new NodePattern([MString("Start")])], new OpAddNode(new MetaEdge(MStrLiteral("NewStartExtension")),new MetaNode(MStrLiteral("NewExpansion")))),
                new Rule([new NodePattern([MString("End")])], new OpAddNode(new MetaEdge(MStrLiteral("NewEndExtension")),new MetaNode(MStrLiteral("NewEndExpansion")))),
			];

            var out = GraphRewriter.applyBest(rewriteGraph, rules, [(_)-> return Seedy.random() * 10]);

            if (out != null) {
                trace('Resulting Graph');

                trace(NodeGraphPrinter.graphToString(out));
            } else {
                trace("No rewrite found");
            }


		}

        // {
        //     var mesh = new HalfEdgeMesh();
    
        //     // Add vertices to the mesh
        //     var v0 = mesh.addVertex(0, 0);
        //     var v1 = mesh.addVertex(1, 0);
        //     var v2 = mesh.addVertex(1, 1);
        //     var v3 = mesh.addVertex(0, 1);
    
        //     // Add a face (quadrilateral) to the mesh
        //     mesh.addFace([v0, v1, v2, v3]);
    
        //     // Compute the dual mesh
        //     var dualMesh = mesh.computeDual();
    
        //     // Output the dual mesh data
        //     trace("Dual Mesh Vertices:");
        //     for (v in dualMesh.vertices) {
        //         trace('(' + v.x + ', ' + v.y + ')');
        //     }
    
        //     trace("Dual Mesh Faces:");
        //     for (f in dualMesh.faces) {
        //         var edge = f.edge;
        //         var vertices = [];
        //         do {
        //             vertices.push(edge.vertex);
        //             edge = edge.next;
        //         } while (edge != f.edge);
    
        //         var s = "";
        //         for (v in vertices) {
        //             s += '(' + v.x + ', ' + v.y + ') ';
        //         }
        //         trace(s);
        //     }
        // }

       testTetrahedron();
       testCube();
       testOctahedron();
       testCoplanarPoints();
       testColinearPoints();
       testDuplicatePoints();
       testRandomPointCloud();
       testLargeDataset();
       powerTestEquilateralTriangle();

       testSquareEqualWeights();
       testSquareRandomWeights();
       testFiveEqualWeights();
       randomEqualWeights();
    }

    static var passedTests = 0;
    static var failedTests = 0;

    private static function logResult(testName:String, passed:Bool, message:String = ""):Void {
        if (passed) {
            trace("PASS: " + testName);
            passedTests++;
        } else {
            trace("FAIL: " + testName + (message != "" ? " - " + message : ""));
            failedTests++;
        }
    }

    
    public static function powerTestEquilateralTriangle():Void {
        var testName = "Equilateral Triangle with Equal Weights";
        try {
            var points2D = [
                WeightedPoint2D.fromPoint2D(new Point2D(0, 0), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(1, 0), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(0.5, Math.sqrt(3)/2), 1)
            ];
            var cells = PowerDiagram.computeCells(points2D, new Point2D(-0.5, -0.5), new Point2D(1.5, 1.5));
            // Expected: Each cell should correspond to one point
            var expectedCells = 3;
            var keys = [for (k in cells.keys()) k];
            var actualCells = keys.length;
            var pass1 = Assert.assertEquals(expectedCells, actualCells, "Number of cells should be " + expectedCells);
            
            // Additional check: Each cell should have at least one dual vertex
            var pass2 = true;
            for (cell in cells) {
                if (cell.length < 1) {
                    pass2 = false;
                    break;
                }
            }
            var pass = pass1 && pass2;
            logResult(testName, pass, pass ? "" : "One or more cells have no dual vertices.");
        } catch (e:String) {
            logResult(testName, false, "Exception occurred: " + e);
        }
    }

     public static function testSquareEqualWeights():Void {
        var testName = "Square with Equal Weights";
        try {
            var points2D = [
                WeightedPoint2D.fromPoint2D(new Point2D(-1, -1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(1, -1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(1, 1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(-1, 1), 1)
            ];
            var cells = PowerDiagram.computeCells(points2D, new Point2D(-2.0, -2.0), new Point2D(2.0, 2.0));
            var expectedCells = 4;
            var actualCells = [for (k in cells.keys()) k ];
            var pass1 = Assert.assertEquals(expectedCells, actualCells.length, "Number of cells should be " + expectedCells);


            trace ('Cells: ${cells}');
            // Check that each cell has at least one dual vertex
            var pass2 = true;
            for (cell in cells) {
                if (cell.length < 1) {
                    pass2 = false;
                    break;
                }
            }
            var pass = pass1 && pass2;

           
			SVGGenerate.writePowerDiagram("pd_equal.svg", cells, points2D);

            logResult(testName, pass, pass ? "" : "One or more cells have no dual vertices.");
        } catch (e:String) {
            logResult(testName, false, "Exception occurred: " + e);
        }
    }

    public static function testSquareRandomWeights():Void {
        var random = new seedyrng.Random(Int64.make(123456789, 987654321));
        var testName = "Square with Random Weights";
        try {
            var points2D = [
                WeightedPoint2D.fromPoint2D(new Point2D(-1, -1), random.random() * 3.0 + 0.5),
                WeightedPoint2D.fromPoint2D(new Point2D(1, -1), random.random() * 3.0 + 0.5),
                WeightedPoint2D.fromPoint2D(new Point2D(1, 1), random.random() * 3.0 + 0.5),
                WeightedPoint2D.fromPoint2D(new Point2D(-1, 1), random.random() * 3.0 + 0.5)
            ];
            var cells = PowerDiagram.computeCells(points2D, new Point2D(-2.0, -2.0), new Point2D(2.0, 2.0));
            var expectedCells = 4;
            var actualCells = [for (k in cells.keys()) k ];
            var pass1 = Assert.assertEquals(expectedCells, actualCells.length, "Number of cells should be " + expectedCells);

            trace ('Cells: ${cells}');
            // Check that each cell has at least one dual vertex
            var pass2 = true;
            for (cell in cells) {
                if (cell.length < 1) {
                    pass2 = false;
                    break;
                }
            }
            var pass = pass1 && pass2;

			SVGGenerate.writePowerDiagram("pd_random.svg", cells, points2D);

            logResult(testName, pass, pass ? "" : "One or more cells have no dual vertices.");
        } catch (e:String) {
            logResult(testName, false, "Exception occurred: " + e);
        }
    }

    public static function testFiveEqualWeights():Void {
        var testName = "Five with Equal Weights";
        try {
            var points2D = [
                WeightedPoint2D.fromPoint2D(new Point2D(-1, -1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(1, -1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(0, 0), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(1, 1), 1),
                WeightedPoint2D.fromPoint2D(new Point2D(-1, 1), 1)
            ];
            var cells = PowerDiagram.computeCells(points2D, new Point2D(-2.0, -2.0), new Point2D(2.0, 2.0));
            var expectedCells = points2D.length;
            var actualCells = [for (k in cells.keys()) k ];
            var pass1 = Assert.assertEquals(expectedCells, actualCells.length, "Number of cells should be " + expectedCells);


            trace ('Cells: ${cells}');
            // Check that each cell has at least one dual vertex
            var pass2 = true;
            for (cell in cells) {
                if (cell.length < 1) {
                    pass2 = false;
                    break;
                }
            }
            var pass = pass1 && pass2;

           
			SVGGenerate.writePowerDiagram("five_equal.svg", cells, points2D);

            logResult(testName, pass, pass ? "" : "One or more cells have no dual vertices.");
        } catch (e:String) {
            logResult(testName, false, "Exception occurred: " + e);
        }
    }

    public static function randomEqualWeights():Void {
        var testName = "Random with Equal Weights";
        try {
            var rand = new Random(Int64.make(334343, 124544));

            var count = rand.randomInt(10, 20);

            var points2D = [];
            for (i in 0...count) {
                points2D.push(new WeightedPoint2D(rand.random() * 10 - 5, rand.random() * 10 - 5, 1));
            }


            var cells = PowerDiagram.computeCells(points2D, new Point2D(-10.0, -10.0), new Point2D(10.0, 10.0));
            var expectedCells = points2D.length;
            var actualCells = [for (k in cells.keys()) k ];
            var pass1 = Assert.assertEquals(expectedCells, actualCells.length, "Number of cells should be " + expectedCells);


            trace ('Cells: ${cells}');
            // Check that each cell has at least one dual vertex
            var pass2 = true;
            for (cell in cells) {
                if (cell.length < 1) {
                    pass2 = false;
                    break;
                }
            }
            var pass = pass1 && pass2;

           
			SVGGenerate.writePowerDiagram("random_equal.svg", cells, points2D);

            logResult(testName, pass, pass ? "" : "One or more cells have no dual vertices.");
        } catch (e:String) {
            logResult(testName, false, "Exception occurred: " + e);
        }
    }


    // Test 1: Tetrahedron
    private static function testTetrahedron():Void {
        trace("\nTest 1: Tetrahedron");
        var points = [
            new Point3D(0, 0, 0),
            new Point3D(1, 0, 0),
            new Point3D(0, 1, 0),
            new Point3D(0, 0, 1)
        ];

        runTest(points,  4);
    }

    // Test 2: Cube
    private static function testCube():Void {
        trace("\nTest 2: Cube");
        var points = [
            new Point3D(0, 0, 0),
            new Point3D(1, 0, 0),
            new Point3D(1, 1, 0),
            new Point3D(0, 1, 0),
            new Point3D(0, 0, 1),
            new Point3D(1, 0, 1),
            new Point3D(1, 1, 1),
            new Point3D(0, 1, 1)
        ];

        runTest(points,  12);
    }

    // Test 3: Octahedron
    private static function testOctahedron():Void {
        trace("\nTest 3: Octahedron");
        var points = [
            new Point3D(1, 0, 0),
            new Point3D(-1, 0, 0),
            new Point3D(0, 1, 0),
            new Point3D(0, -1, 0),
            new Point3D(0, 0, 1),
            new Point3D(0, 0, -1)
        ];

        runTest(points,  8);
    }

    // Test 4: Coplanar Points
    private static function testCoplanarPoints():Void {
        trace("\nTest 4: Coplanar Points");
        var points = [
            new Point3D(0, 0, 0),
            new Point3D(1, 0, 0),
            new Point3D(1, 1, 0),
            new Point3D(0, 1, 0),
            new Point3D(0.5, 0.5, 0)
        ];

        try {
            runTest(points,  0);
        } catch (e:String) {
            trace("Expected Exception: " + e);
        }
    }

    // Test 5: Colinear Points
    private static function testColinearPoints():Void {
        trace("\nTest 5: Colinear Points");
        var points = [
            new Point3D(0, 0, 0),
            new Point3D(1, 1, 1),
            new Point3D(2, 2, 2),
            new Point3D(3, 3, 3)
        ];

        try {
            runTest(points,  0);
        } catch (e:String) {
            trace("Expected Exception: " + e);
        }
    }

    // Test 6: Duplicate Points
    private static function testDuplicatePoints():Void {
        trace("\nTest 6: Duplicate Points");
        var points = [
            new Point3D(0, 0, 0),
            new Point3D(1, 0, 0),
            new Point3D(1, 1, 0),
            new Point3D(0, 1, 0),
            new Point3D(0, 0, 0), // Duplicate
            new Point3D(1, 1, 0)  // Duplicate
        ];

        runTest(points,  4);
    }

    // Test 7: Random Point Cloud
    private static function testRandomPointCloud():Void {
        trace("\nTest 7: Random Point Cloud");
        var points = [];
        var numPoints = 8;
        var rand = new Random(Int64.make(334343, 124544));

        for (i in 0...numPoints) {
            var x = rand.random() * 10 - 5; // Random float between -5 and 5
            var y = rand.random() * 10 - 5;
            var z = rand.random() * 10 - 5;
            points.push(new Point3D(x, y, z));
        }

        runTest(points);
    }

    // Test 8: Large Dataset
    private static function testLargeDataset():Void {
        trace("\nTest 8: Large Dataset");
        var points = [];
        var numPoints = 1000;
        var rand = new Random(Int64.make(12356789, 98764321));

        var pointMap = new Map<String, Bool>();

        for (i in 0...numPoints) {
            var x = rand.random() * 100 - 50;
            var y = rand.random() * 100 - 50;
            var z = rand.random() * 100 - 50;
            var key = x + ',' + y + ',' + z;
            if (pointMap.exists(key)){
                trace('Duplicate point: ' + key);
                continue;
            }
            pointMap.set(key, true);
            points.push(new Point3D(x, y, z));
        }

        runTest(points);
    }

    // Helper function to run a test
    private static function runTest(points:Array<Point3D>, ?expectedFaceCount:Int = null):Void {
        try {
            var quickHull = new QuickHull3D(points);
            var faceCount = quickHull.faces.length;
            trace('Computed Convex Hull with ' + faceCount + ' faces.');

            if (expectedFaceCount != null) {
                if (faceCount == expectedFaceCount) {
                    trace('Test passed: Expected face count matches computed face count.');
                } else {
                    trace('Test failed: Expected ' + expectedFaceCount + ' faces, but got ' + faceCount + ' faces.');
                }
            } else {
                trace('Test completed without expected face count.');
            }

            // Optional: Verify convexity and correctness
            verifyConvexity(quickHull.faces, points);

        } catch (e:String) {
            trace('Exception during convex hull computation: ' + e);
        }
    }

    // Optional function to verify convexity (not implemented here)
    private static function verifyConvexity(faces:Array<FaceMesh3DFace>, points:Array<Point3D>):Void {
        // Check that all faces are correctly oriented and that all points lie on or inside the convex hull
    
        // For each face, verify that:
        // 1. The face is correctly oriented (normals point outward)
        // 2. No point lies outside the convex hull (i.e., in front of any face)
    
        var hullCentroid = computeCentroid(points);

        for (face in faces) {
            // Check if the face normal points away from the interior point
            if (face.isPointAbove(hullCentroid)) {
                throw ('Convexity check failed: Face normal points inward: v ${face.vertices[0]} n ${face.normal} -> c ${hullCentroid}');
            }
    
            // Now, check that no external point lies outside this face
            for (point in points) {
                // Skip the vertices of the face
                if (face.vertices.indexOf(point) != -1) continue;
    
                if (face.isPointAbove(point)) {
                    throw 'Convexity check failed: Point ${point.toString()} lies outside the convex hull by ${face.distanceToPoint(point)} : v ${face.vertices} n ${face.normal} -> ${point}';
                }
            }
        }
    
        trace('Convexity check passed: All points lie on or inside the convex hull, and all faces are correctly oriented.');
    }
    
    
}
