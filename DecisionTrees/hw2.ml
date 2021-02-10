(* Michael Reilly *)
(* hw2.ml *)
(* I pledge my honor that I have abided by the Stevens Honor System. *)

(* Part 1, defining type dtree as well it's leaves and nodes*)
type dtree =
  | Leaf of int
  | Node of (char*dtree*dtree)

(*Part 2, defining tLeft and tRight based on the trees in figure 1*) 
let tLeft = Node('w', Node('x', Leaf(2), Leaf(5)), Leaf(8))

let tRight = Node('w', Node('x', Leaf(2), Leaf(5)), Node('y', Leaf(7), Leaf(5)))

(* Follows the instructions given where dTree_height takes in a tree
and then finds the height of the tree, aka how many layers there are to the tree *)
let rec dTree_height t =
  match t with
  | Leaf(j) -> 0
  | Node(i,lt,rt) -> (max (dTree_height lt) (dTree_height rt) ) + 1

(* Follows the instructions given where dTree_size takes in a tree
and counts how many nodes and leaves are in the tree *)
let rec dTree_size t =
  match t with
  | Leaf(j) -> 1
  | Node(i,lt,rt) -> (dTree_size lt) + (dTree_size rt) + 1

(* Helper function to dTree_paths that concatenates a 0 to a list if a left traversal is made *)
let left_tree l =
  0::l

(* Helper function to dTree_paths that concatenates a 1 to a list if a right traversal is made *)
let right_tree l =
  1::l

(* Follows the instructions given where dTree_paths takes in a tree
and finds the path to all the leaves, with 0 being all left and 1 being right
returned as a list of int lists *)
let rec dTree_paths t =
  match t with
  | Leaf(j) -> [[]]
  | Node(i,lt,rt) -> (List.map left_tree (dTree_paths lt)) @ (List.map right_tree (dTree_paths rt))

(* Follows the instructions given where dTree_is_peerfect takes in a tree
and checks to make sure the depth of both the left and right side of the tree
are the same, using the previously implemented dTree_height function *)
let rec dTree_is_perfect t =
  match t with
  | Leaf(j) -> true
  | Node(i,lt,rt) -> if((dTree_height lt) = (dTree_height rt))
                      then (dTree_is_perfect lt) && (dTree_is_perfect rt)
                      else false

(* Follows the instructions given where dTree_map takes in a function that aplies to chars,
a function that applies to ints, and a tree, and applies the first function to all the nodes
and applies the second function to all the leaves *)
let rec dTree_map f g t =
  match t with
  | Leaf(j) -> Leaf(g j)
  | Node(i,lt,rt) -> Node(f i,(dTree_map f g lt),(dTree_map f g rt))

(* Follows the instructions given where list_to_tree takes in a list, and using the encoding given in the list
makes a corresponding tree to it *)
let rec list_to_tree l =
  match l with
  | [] -> Leaf(0)
  | head::body -> Node(head, list_to_tree body, list_to_tree body)

(* Helper function to replace_leaf_at that takes in the tree and the function
as well as the number of graph encoding to replace the leaves of the tree with *)
let rec replace_leaf_at' t f n =
  match f with
  | [] -> Leaf(n)
  | head::body -> match t with
                  | Node(i,lt,rt) -> if (head = 0)
                  then Node(i,(replace_leaf_at' lt body n),rt)
                  else Node(i,lt,(replace_leaf_at' rt body n))
                  | _ -> failwith "ERROR CASE FOR UBUNTU WARNING"

(* Follows the instructions given where replace_leaf_at takes in a tree and a function
and replaces all the leaves in the tree with their encoding mappings based on the given function
of the tree *)
let rec replace_leaf_at  t f =
  match f with
  | [] -> t
  | (ti,tf)::f' -> replace_leaf_at (replace_leaf_at' t ti tf) f'

(* Follows the instructions given where bf_to_dTree takes in a pair-encoding of boolean functions 
and returns the corresponding tree-encoding given when replacing the leaves
of the tree *)
let rec bf_to_dTree (a,b) =
  replace_leaf_at (list_to_tree a) b
