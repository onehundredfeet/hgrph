package gdoc;

import haxe.ds.StringMap;
using Lambda;


class Edge {
    function new() {

    }

    public var source : Node;
    public var target : Node;
    public var properties = new StringMap<Dynamic>();
    public var name : String;
}

final CHILD_RELATION = "_CHILD";

// Node is a bit heavy, but we're not making giant graphs
class Node {
    function new() {

    }

    public var properties = new StringMap<Dynamic>();
    public var connections  = new Array<Edge>();

    // User data
    public var name : String;
    public var id : Int;
    public var user : Dynamic;

    // Used for drawing
    public var x : Float;
    public var y : Float;
    
    // any
    public inline function getEdges() : Array<Edge> {
        return connections;
    }

    public inline function getEdge(relation:String) : Edge {
        return connections.find((x)->x.name == relation);
    }

    public inline function getEdgesBy(relation: String) : Array<Edge> {
        return connections.filter((x)->x.name == relation);
    }

    public inline function getConnectedNodes() : Iterable<Node> {
        return connections.map((x)->x.target);
    }

    public inline function getConnectedNode(relation: String) : Node {
        return connections.find((x)->x.name == relation).target;
    }

    public inline function getConnectedNodesBy(relation: String) : Iterable<Node> {
        return connections.filter((x)->x.name == relation).map((x)->x.target);
    }

    public inline function getConnectedNodesByNot(relation: String) : Iterable<Node> {
        return connections.filter((x)->x.name != relation).map((x)->x.target);
    }
    
    // outgoing
    public inline function getOutgoingEdges() : Iterable<Edge> {
        return connections.filter((x)->(x.source == this));
    }
    public inline function getOutgoingEdge(relation:String) : Edge {
        return connections.find((x)->(x.source == this && x.name == relation));
    }

    public inline function getOutgoingNodes() : Iterable<Node> {
        return connections.filter((x)->(x.source == this)).map((x)->x.target);
    }

    public inline function getOutgoingNode(relation: String) : Node {
        var e = connections.find((x)->(x.source == this && x.name == relation));
        if (e == null) return null;
        return e.target;
    }
    public inline function getOutgoingEdgesBy(relation: String) : Iterable<Edge> {
        return connections.filter((x)->(x.source == this && x.name == relation));
    }
    public inline function getOutgoingEdgesByNot(relation: String) : Iterable<Edge> {
        return connections.filter((x)->(x.source == this && x.name != relation));
    }

    public function getOutgoingNodesBy(relation: String) : Iterable<Node> {
        return getOutgoingEdgesBy(relation).map((x)->x.target);
    }

    public function getOutgoingNodesByNot(relation: String) : Iterable<Node> {
        return getOutgoingEdgesByNot(relation).map((x)->x.target);
    }

    // incoming
    public inline function getIncomingEdges() : Iterable<Edge> {
        return connections.filter((x)->(x.target == this));
    }
    public inline function getIncomingEdge(relation:String) : Edge {
        return connections.find((x)->(x.target == this && x.name == relation));
    }
    public inline function getIncomingNodes() : Iterable<Node> {
        return getIncomingEdges().map((x)->x.target);
    }
    public inline function getIncomingNode(relation: String) : Node {
        var x = getIncomingEdge(relation);
        if (x == null) return null;
        return x.source;
    }
    public function getIncomingNodesBy(relation: String) : Iterable<Node> {
        return connections.filter((x)->(x.target == this && x.name == relation)).map((x)->x.source);
    }
    public function getIncomingNodesByNot(relation: String) : Iterable<Node> {
        return connections.filter((x)->(x.target == this && x.name != relation)).map((x)->x.source);
    }

    // hierarchy
    public inline function getParent() : Node {
        return getIncomingNode(CHILD_RELATION);
    }
    public var parent(get,never) : Node;
    inline function get_parent() return getParent();


    public inline function getChildrenEdges() : Iterable<Edge> {
        return getOutgoingEdgesBy(CHILD_RELATION);
    }
    public inline function getChildrenNodes() : Iterable<Node> {
        return getOutgoingNodesBy(CHILD_RELATION);
    }
    // exclude hierarhcy
    public inline function getNonChildrenOutgoingEdges() : Iterable<Edge> {
        return getOutgoingEdgesByNot(CHILD_RELATION);
    }
    public inline function getNonChildrenOutgoingNodes() : Iterable<Node> {
        return getOutgoingNodesByNot(CHILD_RELATION);
    }
    public function hasChildNamed(name:String) return connections.find((x) -> (x.source == this && x.name == CHILD_RELATION && x.target.name == name)) != null;
    public function hasChildren() return connections.find((x) -> (x.source == this && x.name == CHILD_RELATION)) != null;
    public function numChildren() return connections.filter((x) -> (x.source == this && x.name == CHILD_RELATION)).length;
    public function getChildNamed(name:String)return connections.find((x) -> (x.source == this && x.name == CHILD_RELATION && x.target.name == name));
    public function root() : Node {
        var parent = getParent();
        if (parent == null) return this;
        return parent.root();
    }
    public function walkOutgoingEdgesNonChildren(f:(Edge) -> Void) {
        for (c in connections) {
            if (c.source == this && c.name != CHILD_RELATION) {
                f(c);
            }
        }
    }

    public function isAncestorOf( n : Node) : Bool {
        if (this == n) return true;
    
        var parent = getParent();

        while (parent != null) {
            if (this == parent) return true;
            parent = parent.getParent();
        }
        return false;
    }

    public function firstCommonAncestor(n : Node) {
        if (this == n) return this;
        if (this.isAncestorOf( n)) return this;
        if (n.isAncestorOf(this)) return n;
        
        var current : Node = this;
    
        while ((current = current.getParent()) != null) {
            if (current.isAncestorOf( n )) 
                return current;
        }
    
        return null;
    }
}


class NodeGraph {
    var _nextId = 0;

    public function new() {

    }

    public function addNode(name : String = null)  {
        var n = @:privateAccess new Node();
        n.id = _nextId++;
        _nodes.push(n);
        n.name = name;
        return n;
    }

    public function connectNodes(source : Node, target : Node, relation : String = null) {
        var arc =  @:privateAccess new Edge();
        _edges.push(arc);
        arc.source = source;
        arc.target = target;
        arc.name = relation;
        source.connections.push(arc);
        target.connections.push(arc);
        return arc;
    }


    public function collapseEdge( edge : Edge, fn : (Edge, source:Node, target:Node, merged:Node) -> Void = null) : Node {
        var source = edge.source;
        var target = edge.target;
        var merged = addNode();
        removeEdge(edge);

        for (c in source.connections) {
            if (c.source == source) {
                c.source = merged;
            } else {
                c.target = merged;
            }
            merged.connections.push(c);
        }

        for (c in target.connections) {
            if (c.source == target) {
                c.source = merged;
            } else {
                c.target = merged;
            }
            merged.connections.push(c);
        }

        source.connections.resize(0);
        target.connections.resize(0);
        _nodes.remove(target);
        _nodes.remove(source);

        if (fn != null) {
            fn(edge, source, target, merged);
        }

        return merged;
    }
    public function subdivideEdge( edge : Edge, copyProperties = true, fn : (edge:Edge, source:Node, target:Node, sourceEdge:Edge, targetEdge:Edge, splitNode:Node) -> Void = null) : Node {
        var source = edge.source;
        var target = edge.target;

        var split = addNode();

        var sourceEdge = connectNodes(source, split);
        var targetEdge = connectNodes(split, target);

        for (prop in edge.properties) {
            sourceEdge.properties.set(prop.key, prop.value);
            targetEdge.properties.set(prop.key, prop.value);
        }

        removeEdge(edge);

        if (fn != null) {
            fn(edge, source, target, sourceEdge, targetEdge, split);
        }
        return split;
    }

    // replaces an edge with a subraph
    public function replaceEdgeWithSubgraph( edge : Edge, sourceNew : Node, targetNew : Node) {
        var source = edge.source;
        var target = edge.target;

        var sourceEdge = connectNodes(source, sourceNew);
        var targetEdge = connectNodes(targetNew, target);

        removeEdge(edge);
    }

    public function replaceNodeWithSubgraph( node : Node, fn : (Edge) -> Node) {
        for (c in node.connections) {
            var newNode = fn(c);
            if (newNode != null) {
                if (c.source == node) {
                    c.source = newNode;
                } else {
                    c.target = newNode;
                }
            }
        }
        node.connections.resize(0);
        removeNode(node);
    }

    public function parentNode(parent : Node, child : Node) {
        return connectNodes(parent, child, CHILD_RELATION);
    }

    public function removeNode(node : Node) {
        _nodes.remove(node);
        for (c in node.connections) {
            if (c.source == node) {
                c.target.connections.remove(c);
            } else {
                c.source.connections.remove(c);
            }
            _edges.remove(c);
        }

        node.connections.resize(0);
    }

    public function removeEdge(edge : Edge) {
        edge.source.connections.remove(edge);
        edge.target.connections.remove(edge);
        _edges.remove(edge);
    }

    public var nodes(get,never) : Array<Node>;
    public var edges(get,never) : Array<Edge>;
    inline function get_nodes() return _nodes;
    inline function get_edges() return _edges;
    
    public inline function numNodes() return _nodes.length;

    var _nodes = new Array<Node>();
    var _edges = new Array<Edge>();

    public function gatherOutgoingRelationNames() : Array<String> {
        var names = new haxe.ds.StringMap<Bool>();
     
        for (n in _nodes) {
            for (c in n.getOutgoingEdges()) {
                if (c.name != null && c.name != null)
                    names.set(c.name, true);
            }
        }

        names.remove(@:privateAccess CHILD_RELATION);

        return [for (k in names.keys()) k];
    }
}


