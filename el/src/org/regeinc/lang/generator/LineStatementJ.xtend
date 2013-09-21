package org.regeinc.lang.generator

import org.regeinc.lang.el.Instruction
import org.regeinc.lang.el.LineStatement
import org.regeinc.lang.el.LocalVariableDeclaration
import org.regeinc.lang.el.Assignment

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
		«IF lineStatement.localVariableDeclaration!=null»«compile(lineStatement.localVariableDeclaration)»«
		ELSEIF lineStatement.assignment!=null»«compile(lineStatement.assignment)»«
		ELSE»«compile(lineStatement.instruction)»«ENDIF»'''

	def compile(LocalVariableDeclaration localVariableDeclaration)'''
		«IF localVariableDeclaration.qualifiedReference.typePrefix !=null»«
			new TypePrefixJ(localVariableDeclaration.qualifiedReference.reference.name).applyConstraint(localVariableDeclaration.qualifiedReference.typePrefix)»«
		ENDIF»«
		IF localVariableDeclaration.qualifiedReference.reference.NOTNULL»«
			TypeJ::instance.compile(localVariableDeclaration.qualifiedReference.reference.parameterizedType)» temp«
				localVariableDeclaration.qualifiedReference.reference.name.toFirstUpper» = «ExpressionJ::instance.compile(localVariableDeclaration.expression)»;
		if(temp«localVariableDeclaration.qualifiedReference.reference.name.toFirstUpper» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «localVariableDeclaration.qualifiedReference.reference.name»");
		}
		«TypeJ::instance.compile(localVariableDeclaration.qualifiedReference.reference.parameterizedType)» «localVariableDeclaration.qualifiedReference.reference.name» = temp«localVariableDeclaration.qualifiedReference.reference.name»;«
		ELSE»«
			TypeJ::instance.compile(localVariableDeclaration.qualifiedReference.reference.parameterizedType)» «localVariableDeclaration.qualifiedReference.reference.name» = «ExpressionJ::instance.compile(localVariableDeclaration.expression)»;«
		ENDIF»'''
	
	def compile(Instruction instruction)'''
		«IF instruction.BREAK»break«
		ELSEIF instruction.CONTINUE»continue«
		ELSEIF instruction.RETURN» return «ExpressionJ::instance.compile(instruction.expression)»«
		ELSEIF instruction.PRINT» System.out.println(«ExpressionJ::instance.compile(instruction.expression)»)«
		ELSE» = «ExpressionJ::instance.compile(instruction.expression)»«ENDIF»;'''
		
	def compile(Assignment assignment)'''
		«IF assignment.THIS»this.«ENDIF»«assignment.reference.name» = «ExpressionJ::instance.compile(assignment.expression)»;'''
}