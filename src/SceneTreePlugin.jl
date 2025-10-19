#######################################################################################################################
###################################################### SCENETREE PLUGIN ###############################################
#######################################################################################################################

module RECSPlugin

export RECSPLUGIN

using Reexport
using Cruise
@reexport using NodeTree

@Notifyer _ON_CHILD_ADDED(n1, n2)
@Notifyer _ON_CHILD_REMOVED(n1, n2)
@Notifyer _ON_NODE_REMOVED(n)

const SCENETREEPLUGIN = CRPlugin()
const TREE = ObjectTree()
PHASE = :postupdate

const ID = add_system!(SCENETREEPLUGIN, TREE)

################################################# PLUGIN LIFECYCLE ####################################################

function Cruise.awake!(n::CRPluginNode{ObjectTree})
	setstatus(n, PLUGIN_OK)
end

function Cruise.update!(n::CRPluginNode{ObjectTree}, dt)
	nodes = BFS_search(n.obj)
	for node in nodes
		process!(node, dt)
	end
end

function Cruise.shutdown!(n::CRPluginNode{ObjectTree})
	for node in TREE.objects
		destroy!(node)
	end
	setstatus(n, PLUGIN_OFF)
end

################################################## OTHER FUNCTIONS #####################################################

ready!(n::AbstractNode) = nothing
process!(n::AbstractNode) = nothing
destroy!(n::AbstractNode) = nothing
destroy!(::Nothing) = nothing

NodeTree.get_tree() = TREE

function addchild(n1,n2)
	add_child(n1, n2)
	ready!(n2)
	_ON_CHILD_ADDED.emit = n1,n2
end

function deletenode(n)
	remove_node(TREE, n)
	_ON_NODE_REMOVED.emit = n
	destroy!(n)
end

function deletechild(n, n2)
	remove_child(n, n2)
	_ON_CHILD_REMOVED.emit = n, n2
	_ON_NODE_REMOVED.emit = n2
	destroy!(n)
end
deletechild(n, i::Int) = deletechild(n, get_children(n)[i])