package org.regeinc.lang.generator

import org.regeinc.lang.el.Instruction
import org.regeinc.lang.el.LineStatement
import org.regeinc.lang.el.LocalVariableDeclaration

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
		ELSE»«compile(lineStatement.instruction)»«ENDIF»'''

	def compile(LocalVariableDeclaration localVariableDeclaration)'''
		«IF localVariableDeclaration.qualifiedReference.typePrefix !=null»«
			new TypePrefixJ(localVariableDeclaration.qualifiedReference.reference.name).applyConstraint(localVariableDeclaration.qualifiedReference.typePrefix)»«
		ENDIF»«
		IF localVariableDeclaration.qualifiedReference.reference.NOTNULL»«
			localVariableDeclaration.qualifiedReference.reference.type.name» temp«
				localVariableDeclaration.qualifiedReference.reference.name.toFirstUpper» = «ExpressionJ::instance.compile(localVariableDeclaration.expression)»;
		if(temp«localVariableDeclaration.qualifiedReference.reference.name.toFirstUpper» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «localVariableDeclaration.qualifiedReference.reference.name»");
		}
		«localVariableDeclaration.qualifiedReference.reference.type.name» «localVariableDeclaration.qualifiedReference.reference.name» = temp«localVariableDeclaration.qualifiedReference.reference.name»;«
		ELSE»«
		localVariableDeclaration.qualifiedReference.reference.type.name» «localVariableDeclaration.qualifiedReference.reference.name» = «ExpressionJ::instance.compile(localVariableDeclaration.expression)»;«
		ENDIF»'''
	
	def compile(Instruction instruction)'''
		«IF instruction.BREAK»break«
		ELSEIF instruction.CONTINUE»continue«
		ELSEIF instruction.RETURN» return «ExpressionJ::instance.compile(instruction.expression)»«
		ELSEIF instruction.PRINT» System.out.println(«ExpressionJ::instance.compile(instruction.expression)»)«
		ELSE»«instruction.reference.name» = «ExpressionJ::instance.compile(instruction.expression)»«ENDIF»;'''
}