package org.regeinc.lang.generator

import org.regeinc.lang.el.LineStatement
import org.regeinc.lang.el.LocalVariableBinding
import org.regeinc.lang.el.LocalVariableDeclaration
import org.regeinc.lang.el.DoWhere
import org.regeinc.lang.el.DoIf
import org.regeinc.lang.el.ReturnStatement
import org.regeinc.lang.el.ContinueStatement
import org.regeinc.lang.el.PrintStatement
import org.regeinc.lang.el.BreakStatement
import org.regeinc.lang.el.Instruction
import org.regeinc.lang.el.Where
import org.regeinc.lang.el.Clause

class LineStatementJ {
	private new(){		
	}
	static LineStatementJ lineStatementJ
	def static LineStatementJ instance(){
		if(lineStatementJ==null)
			lineStatementJ = new LineStatementJ()
		return lineStatementJ
	}
	
	def compile(LineStatement lineStatement)'''
		«IF lineStatement.LETEXPRESSION»«compile(lineStatement.localVariableBinding)»«compile(lineStatement.doWhere)»«
		ELSE»«compile(lineStatement.doWhere)»«ENDIF»'''

	def compile(LocalVariableBinding localVariableBinding)'''
		«compile(localVariableBinding.localVariableDeclaration)»«IF localVariableBinding.list»«compile(localVariableBinding.next)»«ENDIF»'''	

	def compile(LocalVariableDeclaration localVariableDeclaration)'''
		«new SpecificTypeRefJ(localVariableDeclaration.specificTypeRef.typeRef.name).applyConstraint(localVariableDeclaration.specificTypeRef.orTypePrefix)»
		«IF localVariableDeclaration.specificTypeRef.typeRef.NOTNULL»«
		localVariableDeclaration.specificTypeRef.typeRef.type.name» temp«localVariableDeclaration.specificTypeRef.typeRef.name.toFirstUpper» = «InstanceJ::instance.compile(localVariableDeclaration.instance)»;
		if(temp«localVariableDeclaration.specificTypeRef.typeRef.name.toFirstUpper» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «localVariableDeclaration.specificTypeRef.typeRef.name»");
		}«ENDIF»
		«localVariableDeclaration.specificTypeRef.typeRef.type.name» «localVariableDeclaration.specificTypeRef.typeRef.name» = temp«localVariableDeclaration.specificTypeRef.typeRef.name»;
	'''
	
	def compile(DoWhere doWhere)'''
		«IF doWhere.CONTEXTUAL»«compile(doWhere.where, doWhere.doIf)»«ELSE»«compile(doWhere.doIf)»«ENDIF»'''

	def compile(Clause clause, DoIf doIf)'''
		«IF clause.typeRef!=null»for(«clause.typeRef.type.name» «clause.typeRef.name» : «InstanceJ::instance.compile(clause.instance)»){
			«compile(doIf)»
		}«ELSEIF clause.orCondition!=null»if(«ConditionJ::instance.compile(clause.orCondition)»){
			«compile(doIf)»
		}«ENDIF»'''

	def compile(Where where, DoIf doIf)'''
		«IF where.NESTED»«compile(where.where,doIf)»«ELSE»«compile(where.clause,doIf)»«ENDIF»'''

	def compile(DoIf doIf)'''
		«IF doIf.provided!=null»if(«ConditionJ::instance.compile(doIf.provided.orCondition)»){
			«compile(doIf.instruction)»
		}«IF doIf.provided.doIf!=null»else «compile(doIf.provided.doIf)»«ENDIF»«
		ELSE»«compile(doIf.instruction)»«ENDIF»'''
	
	def compile(Instruction instruction)'''
		«IF instruction.breakStatement!=null»«compile(instruction.breakStatement)»
		«ELSEIF instruction.continueStatement!=null»«compile(instruction.continueStatement)»
		«ELSEIF instruction.returnStatement!=null»«compile(instruction.returnStatement)»
		«ELSEIF instruction.printStatement!=null»«compile(instruction.printStatement)»
		«ELSEIF instruction.instance!=null»«IF instruction.ASSIGNMENT»
			«IF instruction.specificTypeRef!=null»
			«instruction.specificTypeRef.typeRef.type.name» temp«instruction.specificTypeRef.typeRef.name.toFirstUpper» = «InstanceJ::instance.compile(instruction.instance)»;
			if(temp«instruction.specificTypeRef.typeRef.name.toFirstUpper» == null){
				throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «instruction.specificTypeRef.typeRef.name»");
			}
			«instruction.specificTypeRef.typeRef.type.name» «instruction.specificTypeRef.typeRef.name» = temp«instruction.specificTypeRef.typeRef.name»;
			«ELSEIF instruction.typeRef!=null»
			«instruction.typeRef.name» = «InstanceJ::instance.compile(instruction.instance)»;
			«ENDIF»«ENDIF»«InstanceJ::instance.compile(instruction.instance)»;«ENDIF»'''
	
	def compile(ReturnStatement returnStatement)'''
		return «IF returnStatement.instance!=null»«InstanceJ::instance.compile(returnStatement.instance)»«ENDIF»'''

	def compile(BreakStatement breakStatement)'''
		if(«ConditionJ::instance.compile(breakStatement.constraint.orCondition)»){
			continue;
		}'''
		
	def compile(ContinueStatement continueStatement)'''
		if(«ConditionJ::instance.compile(continueStatement.constraint.orCondition)»){
			continue;
		}'''
		
	def compile(PrintStatement printStatement)'''
		System.out.println(«InstanceJ::instance.compile(printStatement.instance)»);'''	
	
}