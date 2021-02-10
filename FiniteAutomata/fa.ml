
(* ******************************************** *)
(** Basic functions on finite automata *)
(* ******************************************** *)
(**
   Code stub for assignment 1
*)
(* Michael Reilly *)
(* fa.ml *)
(* I pledge my honor that I have abided by the Stevens Honor System. *)

type symbol = char
type input = char list

type state = string

(* transition function *)
type tf = (state * symbol * state) list

(* initial state * transition function * end state *)
type fa = { states: state list; start:state; tf: tf; final: state list}


(* ******************************************** *)
(* Examples of automata *)
(* ******************************************** *)

let a = {states = ["q0";"q1";"q2"];
         start = "q0";
         tf = [("q0",'a',"q1"); ("q1",'b',"q1"); ("q1",'c',"q2")];
         final = ["q2"]}

let a2 = {states = ["q0";"q1";"q2";"q3";"q4"];
          start = "q0";
          tf = [("q0",'a',"q1"); ("q1",'b',"q1")
               ; ("q1",'c',"q2");  ("q3",'a',"q4")];
          final= ["q2"]
         }
let tf_of_a = [("q0",'a',"q1"); ("q1",'b',"q1"); ("q1",'c',"q2")]

let f = [("q0",'a',"q1")]

let t = [("q0",'a',"q1"); ("q1",'b',"q1"); ("q1",'c',"q2"); ("q0",'a',"q3")]

(* ******************************************** *)
(* Helper functions *)
(* ******************************************** *)

let input_of_string s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []


(* ******************************************** *)
(* Simulating automata *)
(* ******************************************** *)

(* does the intended function as stated in the assignment directions *)
let rec apply_transition_function : tf -> state -> symbol -> state option = fun f st sym ->
    match f with
    | [] -> None
    | (tinitial,symb,tfinal)::t when (tinitial=st) && (symb=sym) -> Some tfinal
    | _ :: t -> apply_transition_function t st sym

(* does the intended function as stated in the assignment directions *)
let rec accept f s =
  (* accept' is a helper function that takes in the same f and s as accept but also saves what
  state the finite automata is currently in so it can know where in the transition function to transfer
  or if it's possible, or instead if there are no results, and then using this, accept can check whether
  the string ends up in an accept state or not *)
    let rec accept' f1 s1 st =
      match s1 with
      | [] -> st
      | sym::symb -> match st with
                      | Some st1 -> accept' f1 symb (apply_transition_function f1.tf st1 sym)
                      | None -> None
    in match accept' f s (Some f.start) with
    | None -> false
    | Some s -> List.mem s f.final

(* helper function to deterministic that does the what is intended based on the hint in the assignment directions *)
let rec next t state symbol =
  match t with
  | [] -> []
  | (tinitial,sym,tfinal)::tf -> if (tinitial=state) && (sym=symbol)
                      then tfinal::next tf state symbol
                      else next tf state symbol

(* does the intended function as stated in the assignment directions *)
let rec deterministic : fa -> bool = fun f ->
(* determinsitic' is a helper function that uses the transition function of the f given
to see if there are any states where the same symbol has multiple results
using the function next, and returns true or false accordingly *)
  let rec deterministic' = function
    | [] -> true
    | (tinitial,sym,tfinal)::t -> match next t tinitial sym with
                      | [] -> deterministic' t
                      | _ -> false
  in deterministic' f.tf

(* does the intended function as stated in the assignment directions *)
let rec valid : fa -> bool = fun f ->
(* is_state is a function that only checks if a given state is in the list
of states in f *)
  let is_state s = 
    List.mem s f.states
  in if (is_state f.start) && (List.for_all is_state f.final) && (deterministic f)
      then true
      else false

(* merger is a helper function to reachaer that merges two lists together without duplicates *)
let rec merger : 'a list -> 'a list -> 'a list = fun l1 l2 ->
    match l1 with
    | [] -> l2
    | index::rest -> if List.mem index l2
                      then merger rest l2
                      else index::merger rest l2

(* does the intended function as given by the assignment directions *)
let rec reachable f =
  (* reachable' checks through all the states of a system, and checks, besides the start state,
  if there is any path from the start state to the other state in the finite automata *)
  let rec reachable' t start sts =
    match t with
    | [] -> []
    | (tinitial,sym,tfinal)::tf -> if (tinitial=start) && (tinitial<>tfinal)
                                    then if List.mem tfinal sts
                                          then reachable' tf start sts
                                          else tfinal::reachable' tf start (tfinal::sts)
                                    else reachable' tf start sts
  (* reach_help takes two states and based on the list resulting from calls using merger
  and reachable listifies all states that have been determined to be able to be reached
  from the start state of the finite automata *)
  in let rec reach_help st1 st2 =
    match st1 with
    | [] -> [f.start]
    | q1::q2 -> if (List.mem q1 st2)
                then reach_help q2 st2
                else q1::reach_help(merger(reachable' f.tf q1(List.append st1 st2)) q2) (List.append [q1] st2)
  in reach_help (reachable' f.tf f.start []) [f.start]

(* helper function to remove_dead_states that finds any states that aren't reachable
within the finite automata given from a list of states and removes them from the list *)
let rec state_remover st1 st2 =
  match st1 with
  | [] -> []
  | q1::q2 -> if (List.mem q1 st2)
              then q1::state_remover q2 st2
              else state_remover q2 st2

(* helper function to remove_dead_states that is similar to state_remover
except it specifically removes any transition functions involving any non-reachable
states as it needs to be handled slightly differently due to it being a list of tuples
rather than a list of state strings *)
let rec remove_from_tf f st =
  match f with
  | [] -> []
  | (tinitial,sym,tfinal)::t -> if (List.mem tinitial st)
                                then (tinitial,sym,tfinal)::remove_from_tf t st
                                else remove_from_tf t st

(* does the intended function as stated by the assignment directions *)
let rec remove_dead_states : fa -> fa = fun f ->
  let st = reachable f in {
    states = st;
    tf = remove_from_tf f.tf st;
    start = f.start;
    final = state_remover f.final st
  }