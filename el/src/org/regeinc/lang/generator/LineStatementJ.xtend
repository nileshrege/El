package org.regeinc.lang.generator

import org.regeinc.lang.el.Clause
import org.regeinc.lang.el.DoIf
import org.regeinc.lang.el.DoWhere
import org.regeinc.lang.el.Instruction
import org.regeinc.lang.el.LineStatement
import org.regeinc.lang.el.LocalVariableBinding
import org.regeinc.lang.el.LocalVariableDeclaration
import org.regeinc.lang.el.Where

import static extension org.regeinc.lang.generator.LineStatementJ.*

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
		«new TypePrefixJ(localVariableDeclaration.specificTypeRef.typeRef.name).applyConstraint(localVariableDeclaration.specificTypeRef.typePrefix)»
		«IF localVariableDeclaration.specificTypeRef.typeRef.NOTNULL»«
		localVariableDeclaration.specificTypeRef.typeRef.type.name» temp«
			localVariableDeclaration.specificTypeRef.typeRef.name.toFirstUpper» = «ExpressionJ::instance.compile(localVariableDeclaration.expression)»;
		if(temp«localVariableDeclaration.specificTypeRef.typeRef.name.toFirstUpper» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «localVariableDeclaration.specificTypeRef.typeRef.name»");
		}«ENDIF»
		«localVariableDeclaration.specificTypeRef.typeRef.type.name» «localVariableDeclaration.specificTypeRef.typeRef.name» = temp«localVariableDeclaration.specificTypeRef.typeRef.name»;
	'''
	
	def compile(DoWhere doWhere)'''
		«IF doWhere.CONTEXTUAL»«compile(doWhere.where, doWhere.doIf)»«ELSE»«compile(doWhere.doIf)»«ENDIF»'''

	def compile(Clause clause, DoIf doIf)'''
		«IF clause.typeRef!=null»for(«clause.typeRef.type.name» «clause.typeRef.name» : «ExpressionJ::instance.compile(clause.expression)»){
			«compile(doIf)»
		}«ELSEIF clause.condition!=null»if(«ConditionJ::instance.compile(clause.condition)»){
			«compile(doIf)»
		}«ENDIF»'''

	def compile(Where where, DoIf doIf)'''
		«IF where.NESTED»«compile(where.where,doIf)»«ELSE»«compile(where.clause,doIf)»«ENDIF»'''

	def compile(DoIf doIf)'''
		«IF doIf.provided!=null»if(«ConditionJ::instance.compile(doIf.provided.condition)»){
			«compile(doIf.instruction)»
		}«IF doIf.provided.doIf!=null»else «compile(doIf.provided.doIf)»«ENDIF»«
		ELSE»«compile(doIf.instruction)»«ENDIF»'''
	
	def compile(Instruction instruction)'''
		«IF instruction.BREAK»break«
		ELSEIF instruction.CONTINUE»continue«
		ELSEIF instruction.RETURN»return «ExpressionJ::instance.compile(instruction.expression)»«
		ELSEIF instruction.PRINT»System.out.println(«ExpressionJ::instance.compile(instruction.expression)»)«
		ELSEIF instruction.expression!=null»«
			ExpressionJ::instance.compile(instruction.expression)»«
			IF instruction.COPY!=null» = «ExpressionJ::instance.compile(instruction.RExpression)»«
			ELSEIF instruction.MOVE!=null» = «ExpressionJ::instance.compile(instruction.RExpression)»;
		«ExpressionJ::instance.compile(instruction.RExpression)» = null«ENDIF»«ENDIF»;'''
}