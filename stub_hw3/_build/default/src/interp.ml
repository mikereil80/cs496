(* Michael Reilly *)
(* I pledge my honor that I have abided by the Stevens Honor System. *)

open Ast
open Ds
             

let rec apply_proc : exp_val -> exp_val -> exp_val ea_result =
  fun f a ->
  match f with
  | ProcVal (id,body,env) ->
    return env >>+
    extend_env id a >>+
    eval_expr body
  | _ -> error "apply_proc: Not a procVal"
and
 eval_expr : expr -> exp_val ea_result = fun e ->
  match e with
  | Int(n) ->
    return @@ NumVal n
  | Var(id) ->
    apply_env id
  | Add(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1+n2)
  | Sub(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1-n2)
  | Mul(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1*n2)
  | Div(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    if n2==0
    then error "Division by zero"
    else return @@ NumVal (n1/n2)
  | Let(id,def,body) ->
    eval_expr def >>= 
    extend_env id >>+
    eval_expr body 
  | ITE(e1,e2,e3) ->
    eval_expr e1 >>=
    bool_of_boolVal >>= fun b ->
    if b 
    then eval_expr e2
    else eval_expr e3
  | IsZero(e) ->
    eval_expr e >>=
    int_of_numVal >>= fun n ->
    return @@ BoolVal (n = 0)
  | Proc(id,e)  ->
    lookup_env >>= fun en ->
    return (ProcVal(id,e,en))
  | App(e1,e2)  -> 
    eval_expr e1 >>= fun v1 ->
    eval_expr e2 >>= fun v2 ->
    apply_proc v1 v2 
  | Abs(e1)      ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n ->
    if (n>0)
    then return @@ NumVal(n)
    else return @@ NumVal((n) * (-1))
  | Cons(e1, e2) ->
    eval_expr e1 >>= fun v1 ->
    eval_expr e2 >>= fun v2 ->
    (match v2 with
     | ListVal l -> return (ListVal(v1::l))
     | _ -> error "The second argument is not a list!")
  | Hd(e1) ->
    eval_expr e1 >>= fun l1 ->
    (match l1 with
    | ListVal [] -> return (ListVal [])
    | ListVal [head] -> return (ListVal [head])
    | ListVal ([head;tail]) -> return (ListVal [head])
    | _ -> error "The argument is not a list!")
  | Tl(e1) ->
    eval_expr e1 >>= fun l1 ->
    (match l1 with
    | ListVal [] -> return (ListVal [])
    | ListVal [head] -> return (ListVal [])
    | ListVal ([head;tail]) -> return (ListVal [tail])
    | _ -> error "The argument is not a list!")
  | Empty(e1) ->
    eval_expr e1 >>= fun l1 ->
    (match l1 with
    | ListVal [] -> return (BoolVal true)
    | ListVal _ -> return (BoolVal false)
    | TreeVal Empty -> return (BoolVal true)
    | TreeVal _ -> return (BoolVal false)
    | _ -> error "The argument is not a list or a tree!")
  | EmptyList ->
    return (ListVal([]))
  | EmptyTree ->
    return (TreeVal(Empty))
  | Node(e1,lte,rte) ->
    eval_expr e1 >>= fun v1 ->
    eval_expr lte >>= fun left ->
    eval_expr rte >>= fun right ->
    (match left,right with
    | TreeVal l, TreeVal r -> return (TreeVal(Node(v1,l,r)))
    | _, _ -> error "At least one of the arguments is not a tree!")
  | CaseT(target,emptycase,id1,id2,id3,nodecase) ->
    eval_expr target >>= fun t ->
    (match t with
    | TreeVal Empty -> eval_expr emptycase
    | TreeVal Node(i, left, right) -> (extend_env id1 i) >>+
                                      (extend_env id2 (TreeVal(left))) >>+ 
                                      (extend_env id3 (TreeVal(right))) >>+
                                      eval_expr nodecase
    | _ -> error "The argument is not a tree!")
and
  eval_prog (AProg e) = eval_expr e

(***********************************************************************)
(* Everything above this is essentially the same as we saw in lecture. *)
(***********************************************************************)

(* Parse a string into an ast *)

let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

let lexer s =
  let lexbuf = Lexing.from_string s
  in Lexer.read lexbuf 


(* Interpret an expression *)
let interp (e:string) : exp_val result =
  let c = e |> parse |> eval_prog
  in run c



